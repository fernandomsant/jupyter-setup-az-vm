#!/bin/bash

USER_HOME="/home/azureuser"
sudo -u azureuser bash -i <<EOF
export HOME=$USER_HOME
cd \$HOME
wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh"
bash Miniforge3.sh -b -p "\$HOME/conda"
\$HOME/conda/bin/conda create -n jupyter_env python=3.13 notebook=7.4.4 -c conda-forge -c defaults -y
\$HOME/conda/bin/conda run -n jupyter_env jupyter notebook --generate-config
mkdir -p \$HOME/.jupyter
\$HOME/conda/bin/conda run -n jupyter_env jupyter notebook --ip=0.0.0.0 --port=8888 >> \$HOME/.jupyter/jupyter.log 2>&1 &

EOF
