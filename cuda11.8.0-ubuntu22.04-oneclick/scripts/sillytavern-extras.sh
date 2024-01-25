#!/bin/bash

# Parameters
secure=false
use_cpu=false
use_sd_cpu=false
extras_enable_websearch=true
extras_enable_caption=true
captioning_model="Salesforce/blip-image-captioning-large"
extras_enable_classify=true
classification_model="nateraw/bert-base-uncased-emotion"
extras_enable_summarize=true
summarization_model="slauw87/bart_summarisation"
extras_enable_rvc=false
extras_enable_sd=true
sd_model="ckpt/anything-v4.5-vae-swapped"
extras_enable_chromadb=true

# Generate a random API key
api_key=$(openssl rand -hex 5)
echo "API Key generated: $api_key"
echo $api_key > ./api_key.txt

# Define parameters and modules
params=("--share")
modules=("caption" "summarize" "classify" "sd" "chromadb")

[[ "$use_cpu" == true ]] && params+=("--cpu")
[[ "$use_sd_cpu" == true ]] && params+=("--sd-cpu")
[[ "$secure" == true ]] && params+=("--secure")
[[ "$extras_enable_rvc" == true ]] && { modules+=("rvc"); params+=("--max-content-length=2000"); params+=("--rvc-save-file"); }
[[ "$extras_enable_websearch" == true ]] && modules+=("websearch")

params+=("--classification-model=$classification_model")
params+=("--summarization-model=$summarization_model")
params+=("--captioning-model=$captioning_model")
params+=("--sd-model=$sd_model")
params+=("--enable-modules=$(IFS=,; echo "${modules[*]}")")

# Clone repositories and install dependencies
cd /
git clone https://github.com/SillyTavern/SillyTavern-extras
cd /SillyTavern-extras
git clone https://github.com/Cohee1207/tts_samples
npm install -g localtunnel
pip install -r requirements.txt
wget https://github.com/cloudflare/cloudflared/releases/download/2023.5.0/cloudflared-linux-amd64 -O /tmp/cloudflared-linux-amd64
chmod +x /tmp/cloudflared-linux-amd64

if [[ "$extras_enable_rvc" == true ]]; then
  pip install -r requirements-rvc.txt
fi

# Run the server
cmd="python server.py ${params[*]}"
echo $cmd
$cmd &
extras_process_pid=$!
echo "processId: $extras_process_pid"
