#!/bin/bash
#
# Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#

APP_TITLE="Hello AI World (jetson-inference)"
OUTPUT_DIR="../data/networks"
LOG="[jetson-inference] "
WGET_QUIET="--quiet"


#
# exit message for user
#
function exit_message()
{
	echo " "
	echo "$LOG to run this tool again, use the following commands:"
	echo " "
	echo "    $ cd <jetson-inference>/tools"
	echo "    $ ./download-models.sh"
	echo " "

	exit $1
}

#
# prompt user for retry
#
function retry_prompt()
{
	dialog --backtitle "$APP_TITLE" \
			  --title "Download Error" \
			  --colors \
			  --extra-button \
			  --extra-label "Next" \
			  --cancel-label "Quit" \
			  --ok-label "Retry" \
			  --yesno "\nFailed to download '$1' (error code=$2)\n\nWould you like to try downloading it again?\n\n\ZbNote:\Zn  if this error keeps occuring, see here:\n https://github.com/dusty-nv/jetson-inference/releases" 12 60

	local retry_status=$?
	clear

	WGET_QUIET="--verbose"

	if [ $retry_status = 1 ]; then
		echo "$LOG models failed to download (they may not load at runtime)"
		exit_message 1
	elif [ $retry_status != 0 ]; then
		return 1
	fi

	return 0
}


#
# try to download a file from URL
#
function attempt_download_file()
{
	local filename=$1
	local URL=$2
	
	wget $WGET_QUIET --show-progress --progress=bar:force:noscroll --no-check-certificate $URL -O $filename
	
	local wget_status=$?

	if [ $wget_status != 0 ]; then
		echo "$LOG wget failed to download '$filename' (error code=$wget_status)"
		return $wget_status
	fi

	mv $filename $OUTPUT_DIR
	return 0
}


#
# download a file from URL
#
function download_file()
{
	local filename=$1
	local URL=$2
	
	WGET_QUIET="--quiet"

	while true; do
		attempt_download_file $filename $URL

		local download_status=$?

		if [ $download_status = 0 ]; then
			return 0
		fi

		retry_prompt $filename $download_status
	
		local retry_status=$?

		if [ $retry_status != 0 ]; then
			return 0
		fi
	done
}


#
# try to download/extract an archive
#
function attempt_download_archive()
{
	local filename=$1
	local URL=$2
	
	wget $WGET_QUIET --show-progress --progress=bar:force:noscroll --no-check-certificate $URL -O $filename
	
	local wget_status=$?

	if [ $wget_status != 0 ]; then
		echo "$LOG wget failed to download '$filename' (error code=$wget_status)"
		return $wget_status
	fi

	tar -xzf $filename -C $OUTPUT_DIR

	local tar_status=$?

	if [ $tar_status != 0 ]; then
		echo "$LOG tar failed to extract '$filename' (error code=$tar_status)"
		return $tar_status
	fi

	rm $filename
	return 0
}


#
# download/extract an archive
#
function download_archive()
{
	local filename=$1
	local URL=$2
	
	WGET_QUIET="--quiet"

	while true; do
		attempt_download_archive $filename $URL

		local download_status=$?

		if [ $download_status = 0 ]; then
			return 0
		fi

		retry_prompt $filename $download_status
	
		local retry_status=$?

		if [ $retry_status != 0 ]; then
			return 0
		fi
	done
}

#
# IMAGE RECOGNITION
#
function download_alexnet()
{
	echo "$LOG Downloading AlexNet..."

	download_file "bvlc_alexnet.caffemodel" "https://nvidia.box.com/shared/static/5j264j7mky11q8emy4q14w3r8hl5v6zh.caffemodel"
	download_file "alexnet.prototxt" "https://nvidia.box.com/shared/static/c84wp3axbtv4e2gybn40jprdquav9azm.prototxt"
	download_file "alexnet_noprob.prototxt" "https://nvidia.box.com/shared/static/o0w0sl3obqxj21u09c0cwzw4khymz7hh.prototxt"
}

function download_googlenet()
{
	echo "$LOG Downloading GoogleNet..."

	download_file "bvlc_googlenet.caffemodel" "https://nvidia.box.com/shared/static/at8b1105ww1c5h7p30j5ko8qfnxrs0eg.caffemodel" 
	download_file "googlenet.prototxt" "https://nvidia.box.com/shared/static/5z3l76p8ap4n0o6rk7lyasdog9f14gc7.prototxt"
	download_file "googlenet_noprob.prototxt" "https://nvidia.box.com/shared/static/ue8qrqtglu36andbvobvaaj8egxjaoli.prototxt"
}

function download_googlenet12()
{
	echo "$LOG Downloading GoogleNet-12..."
	download_archive "GoogleNet-ILSVRC12-subset.tar.gz" "https://nvidia.box.com/shared/static/zb8i3zcg39sdjjxfty7o5935hpbd64y4.gz" 
}

function download_resnet18()
{
	echo "$LOG Downloading ResNet-18..."
	download_archive "ResNet-18.tar.gz" "https://nvidia.box.com/shared/static/gph1qfor89vh498op8cicvwc13zltu3h.gz" 
}

function download_resnet50()
{
	echo "$LOG Downloading ResNet-50..."
	download_archive "ResNet-50.tar.gz" "https://nvidia.box.com/shared/static/ht46fmnwvow0o0n0ke92x6bzkht8g5xb.gz" 
}

function download_resnet101()
{
	echo "$LOG Downloading ResNet-101..."
	download_archive "ResNet-101.tar.gz" "https://nvidia.box.com/shared/static/7zog25pu70nxjh2irni49e5ujlg4dl82.gz" 
}

function download_resnet152()
{
	echo "$LOG Downloading ResNet-152..."
	download_archive "ResNet-152.tar.gz" "https://nvidia.box.com/shared/static/6t621ru1i054vscvhx3rqck8597es7w8.gz" 
}

function download_vgg16()
{
	echo "$LOG Downloading VGG-16..."
	download_archive "VGG-16.tar.gz" "https://nvidia.box.com/shared/static/ar2ttdpnw1drzxnvpw0umzkw67fka3h0.gz" 
}

function download_vgg19()
{
	echo "$LOG Downloading VGG-19..."
	download_archive "VGG-19.tar.gz" "https://nvidia.box.com/shared/static/1ubk73f1akhh4h7mo0iq7erars7j5yyu.gz" 
}

function download_inception_v4()
{
	echo "$LOG Downloading Inception-v4..."
	download_archive "Inception-v4.tar.gz" "https://nvidia.box.com/shared/static/maidbjiwkg6bz2bk7drwq7rj8v4whdl9.gz" 
}

function download_recognition()
{
	echo "$LOG Downloading all Image Recognition models..."

	download_alexnet

	download_googlenet
	download_googlenet12

	download_resnet18
	download_resnet50
	download_resnet101
	download_resnet152

	download_vgg16
	download_vgg19

	download_inception_v4

	ALL_RECOGNITION=1
}


#
# OBJECT DETECTION
#
function download_pednet()
{
	echo "$LOG Downloading PedNet..."
	download_archive "ped-100.tar.gz" "https://nvidia.box.com/shared/static/0wbxo6lmxfamm1dk90l8uewmmbpbcffb.gz" 
}

function download_multiped()
{
	echo "$LOG Downloading MultiPed..."
	download_archive "multiped-500.tar.gz" "https://nvidia.box.com/shared/static/r3bq08qh7zb0ap2lf4ysjujdx64j8ofw.gz" 
}

function download_facenet()
{
	echo "$LOG Downloading FaceNet..."
	download_archive "facenet-120.tar.gz" "https://nvidia.box.com/shared/static/wjitc00ef8j6shjilffibm6r2xxcpigz.gz" 
}

function download_detectnet_coco_dog()
{
	echo "$LOG Downloading DetectNet-COCO-Dog..."
	download_archive "DetectNet-COCO-Dog.tar.gz" "https://nvidia.box.com/shared/static/3qdg3z5qvl8iwjlds6bw7bwi2laloytu.gz" 
}

function download_detectnet_coco_chair()
{
	echo "$LOG Downloading DetectNet-COCO-Chair..."
	download_archive "DetectNet-COCO-Chair.tar.gz" "https://nvidia.box.com/shared/static/fq0m0en5mmssiizhs9nxw3xtwgnoltf2.gz" 
}

function download_detectnet_coco_bottle()
{
	echo "$LOG Downloading DetectNet-COCO-Bottle..."
	download_archive "DetectNet-COCO-Bottle.tar.gz" "https://nvidia.box.com/shared/static/8bhm91o9yldpf97dcz5d0welgmjy7ucw.gz" 
}

function download_detectnet_coco_airplane()
{
	echo "$LOG Downloading DetectNet-COCO-Airplane..."
	download_archive "DetectNet-COCO-Airplane.tar.gz" "https://nvidia.box.com/shared/static/xi71hlsht5b0y66loeg73rxfa73q561s.gz" 
}

function download_ssd_mobilenet_v1()
{
	echo "$LOG Downloading SSD-Mobilenet-v1..."
	download_archive "SSD-Mobilenet-v1.tar.gz" "https://nvidia.box.com/shared/static/0pg3xi9opwio65df14rdgrtw40ivbk1o.gz" 
}

function download_ssd_mobilenet_v2()
{
	echo "$LOG Downloading SSD-Mobilenet-v2..."
	download_archive "SSD-Mobilenet-v2.tar.gz" "https://nvidia.box.com/shared/static/jcdewxep8vamzm71zajcovza938lygre.gz" 
}

function download_ssd_inception_v2()
{
	echo "$LOG Downloading SSD-Inception-v2..."
	download_archive "SSD-Inception-v2.tar.gz" "https://nvidia.box.com/shared/static/mjq1cel6r5mdk94yb9o6v4nj8gxzlflr.gz" 
}

function download_detection()
{
	echo "$LOG Downloading all Object Detection models..."

	download_ssd_mobilenet_v1
	download_ssd_mobilenet_v2
	download_ssd_inception_v2

	download_pednet
	download_multiped
	download_facenet

	download_detectnet_coco_dog
	download_detectnet_coco_bottle
	download_detectnet_coco_chair
	download_detectnet_coco_airplane

	ALL_DETECTION=1
}


#
# SEMANTIC SEGMENTATION
#
function download_fcn_resnet18_cityscapes_512x256()
{
	echo "$LOG Downloading FCN-ResNet18-Cityscapes-512x256..."
	download_archive "FCN-ResNet18-Cityscapes-512x256.tar.gz" "https://nvidia.box.com/shared/static/k7s7gdgi098309fndm2xbssj553vf71s.gz" 
}

function download_fcn_resnet18_cityscapes_1024x512()
{
	echo "$LOG Downloading FCN-ResNet18-Cityscapes-1024x512..."
	download_archive "FCN-ResNet18-Cityscapes-1024x512.tar.gz" "https://nvidia.box.com/shared/static/9aqg4gpjmk7ipz4z0raa5mvs35om6emy.gz" 
}

function download_fcn_resnet18_cityscapes_2048x1024()
{
	echo "$LOG Downloading FCN-ResNet18-Cityscapes-2048x1024..."
	download_archive "FCN-ResNet18-Cityscapes-2048x1024.tar.gz" "https://nvidia.box.com/shared/static/ylh3d2qk8qvitalq8sy803o7avrb6w0h.gz" 
}

function download_fcn_resnet18_deepscene_576x320()
{
	echo "$LOG Downloading FCN-ResNet18-DeepScene-576x320..."
	download_archive "FCN-ResNet18-DeepScene-576x320.tar.gz" "https://nvidia.box.com/shared/static/jm0zlezvweiimpzluohg6453s0u0nvcv.gz" 
}

function download_fcn_resnet18_deepscene_864x480()
{
	echo "$LOG Downloading FCN-ResNet18-DeepScene-864x480..."
	download_archive "FCN-ResNet18-DeepScene-864x480.tar.gz" "https://nvidia.box.com/shared/static/gooux9b5nknk8wlk60ou9s2unpo760iq.gz" 
}

function download_fcn_resnet18_mhp_512x320()
{
	echo "$LOG Downloading FCN-ResNet18-MHP-512x320..."
	download_archive "FCN-ResNet18-MHP-512x320.tar.gz" "https://nvidia.box.com/shared/static/dgaw0ave3bdws1t5ed333ftx5dbpt9zv.gz" 
}

function download_fcn_resnet18_mhp_640x360()
{
	echo "$LOG Downloading FCN-ResNet18-MHP-640x360..."
	download_archive "FCN-ResNet18-MHP-640x360.tar.gz" "https://nvidia.box.com/shared/static/50mvlrjwbq9ugkmnnqp1sm99g2j21sfn.gz" 
}

function download_fcn_resnet18_pascal_voc_320x320()
{
	echo "$LOG Downloading FCN-ResNet18-Pascal-VOC-320x320..."
	download_archive "FCN-ResNet18-Pascal-VOC-320x320.tar.gz" "https://nvidia.box.com/shared/static/p63pgrr6tm33tn23913gq6qvaiarydaj.gz" 
}

function download_fcn_resnet18_pascal_voc_512x320()
{
	echo "$LOG Downloading FCN-ResNet18-Pascal-VOC-512x320..."
	download_archive "FCN-ResNet18-Pascal-VOC-512x320.tar.gz" "https://nvidia.box.com/shared/static/njup7f3vu4mgju89kfre98olwljws5pk.gz" 
}

function download_fcn_resnet18_sun_rgbd_512x400()
{
	echo "$LOG Downloading FCN-ResNet18-SUN-RGBD-512x400..."
	download_archive "FCN-ResNet18-SUN-RGBD-512x400.tar.gz" "https://nvidia.box.com/shared/static/5vs9t2wah5axav11k8o3l9skb7yy3xgd.gz" 
}

function download_fcn_resnet18_sun_rgbd_640x512()
{
	echo "$LOG Downloading FCN-ResNet18-SUN-RGBD-640x512..."
	download_archive "FCN-ResNet18-SUN-RGBD-640x512.tar.gz" "https://nvidia.box.com/shared/static/z5llxysbcqd8zzzsm7vjqeihs7ihdw20.gz" 
}

function download_segmentation()
{
	echo "$LOG Downloading all Semantic Segmentation models..."

	download_fcn_resnet18_cityscapes_512x256
	download_fcn_resnet18_cityscapes_1024x512
	download_fcn_resnet18_cityscapes_2048x1024
	download_fcn_resnet18_deepscene_576x320
	download_fcn_resnet18_deepscene_864x480
	download_fcn_resnet18_mhp_512x320
	download_fcn_resnet18_mhp_640x360
	download_fcn_resnet18_pascal_voc_320x320
	download_fcn_resnet18_pascal_voc_512x320
	download_fcn_resnet18_sun_rgbd_512x400
	download_fcn_resnet18_sun_rgbd_640x512
	
	ALL_SEGMENTATION=1
}


#
# SEMANTIC SEGMENTATION (legacy)
#
function download_fcn_alexnet_cityscapes_sd()
{
	echo "$LOG Downloading FCN-Alexnet-Cityscapes-SD..."
	download_archive "FCN-Alexnet-Cityscapes-SD.tar.gz" "https://nvidia.box.com/shared/static/pa5d338t9ntca5chfbymnur53aykhall.gz" 
}

function download_fcn_alexnet_cityscapes_hd()
{
	echo "$LOG Downloading FCN-Alexnet-Cityscapes-HD..."
	download_archive "FCN-Alexnet-Cityscapes-HD.tar.gz" "https://nvidia.box.com/shared/static/mh121fvmveemujut7d8c9cbmglq18vz3.gz" 
}

function download_fcn_alexnet_aerial_fpv()
{
	echo "$LOG Downloading FCN-Alexnet-Aerial-FPV..."
	download_archive "FCN-Alexnet-Aerial-FPV-720p.tar.gz" "https://nvidia.box.com/shared/static/y1mzlwkmytzwg2m7akt7tcbsd33f9opz.gz" 
}

function download_fcn_alexnet_pascal_voc()
{
	echo "$LOG Downloading FCN-Alexnet-Pascal-VOC..."
	download_archive "FCN-Alexnet-Pascal-VOC.tar.gz" "https://nvidia.box.com/shared/static/xj20b6qopfwkkpqm12ffiuaekk6bs8op.gz" 
}

function download_fcn_alexnet_synthia_cvpr()
{
	echo "$LOG Downloading FCN-Alexnet-Synthia-CVPR..."
	download_archive "FCN-Alexnet-SYNTHIA-CVPR16.tar.gz" "https://nvidia.box.com/shared/static/u5ey2ws0nbtzyqyftkuqazx1honw6wry.gz" 
}

function download_fcn_alexnet_synthia_summer_sd()
{
	echo "$LOG Downloading FCN-Alexnet-Synthia-Summer-SD..."
	download_archive "FCN-Alexnet-SYNTHIA-Summer-SD.tar.gz" "https://nvidia.box.com/shared/static/vbk5ofu1x2hwp9luanbg4o0vrfub3a7j.gz" 
}

function download_fcn_alexnet_synthia_summer_hd()
{
	echo "$LOG Downloading FCN-Alexnet-Synthia-Summer-HD..."
	download_archive "FCN-Alexnet-SYNTHIA-Summer-HD.tar.gz" "https://nvidia.box.com/shared/static/ydgmqgdhbvul6q9avoc9flxr3fdoa8pw.gz" 
}

function download_segmentation_legacy()
{
	echo "$LOG Downloading all Semantic Segmentation (Legacy) models..."

	download_fcn_alexnet_cityscapes_sd
	download_fcn_alexnet_cityscapes_hd
	download_fcn_alexnet_aerial_fpv
	download_fcn_alexnet_pascal_voc
	download_fcn_alexnet_synthia_cvpr
	download_fcn_alexnet_synthia_summer_sd
	download_fcn_alexnet_synthia_summer_hd

	ALL_SEGMENTATION_LEGACY=1
}


#
# IMAGE PROCESSING
#
function download_deep_homography_coco()
{
	echo "$LOG Downloading Deep-Homography-COCO..."
	download_archive "Deep-Homography-COCO.tar.gz" "https://nvidia.box.com/shared/static/nlqbsdnt76y0nmkwdzxkg4zbvhk4bidh.gz" 
}

function download_super_resolution_bsd500()
{
	echo "$LOG Downloading Super-Resolution-BSD500..."
	download_archive "Super-Resolution-BSD500.tar.gz" "https://nvidia.box.com/shared/static/a99l8ttk21p3tubjbyhfn4gh37o45rn8.gz" 
}

function download_image_processing()
{
	echo "$LOG Downloading all Image Processing models..."

	download_deep_homography_coco
	download_super_resolution_bsd500

	ALL_IMAGE_PROCESSING=1
}


#
# check if a particular deb package is installed with dpkg-query
# arg $1 -> package name
# arg $2 -> variable name to output status to (e.g. HAS_PACKAGE=1)
#
function find_deb_package()
{
	local PKG_NAME=$1
	local HAS_PKG=`dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed"`

	if [ "$HAS_PKG" == "" ]; then
		echo "$LOG Checking for '$PKG_NAME' deb package...not installed"
	else
		echo "$LOG Checking for '$PKG_NAME' deb package...installed"
		eval "$2=INSTALLED"
	fi
}


#
# install a debian package if it isn't already installed
# arg $1 -> package name
# arg $2 -> variable name to output status to (e.g. FOUND_PACKAGE=INSTALLED)
#
function install_deb_package()
{
	local PKG_NAME=$1
	
	# check to see if the package is already installed
	find_deb_package $PKG_NAME $2

	# if not, install the package
	if [ -z $2 ]; then
		echo "$LOG Missing '$PKG_NAME' deb package...installing '$PKG_NAME' package."
		sudo apt-get --force-yes --yes install $PKG_NAME
	else
		return 0
	fi
	
	# verify that the package was installed
	find_deb_package $PKG_NAME $2
	
	if [ -z $2 ]; then
		echo "$LOG Failed to install '$PKG_NAME' deb package."
		return 1
	else
		echo "$LOG Successfully installed '$PKG_NAME' deb package."
		return 0
	fi
}


# check for dialog package
install_deb_package "dialog" FOUND_DIALOG
echo "$LOG FOUND_DIALOG=$FOUND_DIALOG"

# use customized RC config
export DIALOGRC=./download-models.rc


#
# main menu
#
while true; do

	download_ssd_mobilenet_v2
	download_ssd_inception_v2
	exit_message 0
done

