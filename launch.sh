#!/bin/bash

# As there are not key-value lists on bash versions lower to 4 and mac computers cannot have that version, 
# this is a way to create this key-value list
notebook_care2d="CARE_2D"
notebook_care3d="CARE_3D"
notebook_cyclegan="CycleGAN"
notebook_deepstorm2d="Deep-STORM_2D"
notebook_noise2void2d="Noise2Void_2D"
notebook_noise2void3d="Noise2Void_3D"
notebook_stardist2d="StarDist_2D"
notebook_stardist3d="StarDist_3D"
notebook_unet2d="U-Net_2D"
notebook_unet3d="U-Net_3D"
notebook_unet2dmultilabel="U-Net_2D_Multilabel"
notebook_yolov2="YOLOv2"
notebook_fnet2d="fnet_2D"
notebook_fnet3d="fnet_3D"
notebook_pix2pix="pix2pix"

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] -v version -n notebook_name

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --version   Version of the notebook
-n, --name      Name of the notebook:  - care2d
                                       - care3d
                                       - cyclegan
                                       - deepstorm2d
                                       - noise2void2d
                                       - noise2void3d
                                       - stardist2d
                                       - stardist3d
                                       - unet2d
                                       - unet3d
                                       - unet2dmultilabel
                                       - yolov2
                                       - fnet2d
                                       - fnet3d
                                       - pix2pix
-d --data_path  Path to the data directory

EOF
  exit
}

parse_yaml() {
  
  local prefix=$2
  local s='[[:space:]]*'
  local w='[a-zA-Z0-9_]*'
  local fs=$(echo @|tr @ '\034')
  
  sed "h;s/^[^:]*//;x;s/:.*$//;y/-/_/;G;s/\n//" $1 |
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;

    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
        vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
        printf("%s%s%s : \"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}


while getopts :hv:n:d: flag;do
   case $flag in 
      h)
        usage ;;
      v)
        version="$OPTARG" ;;
      n)
        name="$OPTARG" ;;
      d)
        data_path="$OPTARG" ;;
      \?)
        echo "Invalid option: -$OPTARG"
        echo "Try bash ./test.sh -h for more information."
        exit ;;
   esac
done

if [ -z "$name" ]; then 
   echo "No notebook name has been specified, please make sure to use -n --name argument and give a value to it."
   exit
else
   echo "Notebook name: $name"
   notebook_name=notebook_$name
   echo ${!notebook_name}
   if [ -z "${!notebook_name}" ]; then
      echo "No such name for the notebook" 
      exit
   else
      echo "Actual notebook: ${!notebook_name}" 
   fi
fi 

if [ -z "$version" ]; then 
   echo "No version has been specified, please make sure to use -v --version argument and give a value to it."
   exit
else
   echo "Version: $version"
fi 

if [ -z "$data_path" ]; then 
   echo "No data path has been specified, please make sure to use -d --data_path argument and give a value to it."
   exit
else
   echo "Path to the data: $data_path"
fi 

echo ""

echo "Configuration in the yaml file:"
eval parse_yaml notebooks/${!notebook_name}_DL4Mic/configuration.yaml
echo ""

docker build \
       --build-arg="BASE_IMAGE=${base_img}" \
       --build-arg CACHEBUST=$(date +%s) \
       --build-arg="NOTEBOOK_NAME=${!notebook_name}_DL4Mic.ipynb" \
       --build-arg="PATH_TO_NOTEBOOK=${notebook_url}" \
       --build-arg="PATH_TO_REQUIREMENTS=${requirements_url}" \
       --build-arg="SECTIONS_TO_REMOVE=${sections_to_remove}" \
       -t $${!notebook_name}_dl4mic .

docker run -it --gpus all -p 8888:8888 -v $data_path:/home/dataset ${!notebook_name}_dl4mic