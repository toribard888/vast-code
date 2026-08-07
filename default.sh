#!/bin/bash

# ============================================================================
# vast.ai ComfyUI provisioning script (default.sh)
#
# ローカル環境 (E:\Comfy-Desktop) と同じモデル・カスタムノード構成を
# vast.ai の ComfyUI インスタンスに再現するためのセットアップスクリプト。
#
# 【使い方】
# 1. vast.ai コンソール → Templates → ComfyUI テンプレートを選択し、
#    "On-Start Script"（PROVISIONING_SCRIPT）にこのファイルの内容を指定。
# 2. インスタンス作成時に以下を推奨:
#    - Disk: 100GB 以上（モデル合計 約51GB + 環境）
#    - GPU : VRAM 24GB 以上（MiniMax H3 の diffusion model が 約21GB）
# 3. プライベート（early access 等）モデルの場合のみ、下の
#    「TOKEN 設定エリア」または vast.ai の環境変数で CIVITAI_TOKEN を設定。
#
# 【注意】
# - ローカルの Minimax H3 3ファイル（diffusion_models / text_encoders /
#   video_vae）は不完全なダウンロードだったため、ここでは HuggingFace から
#   完全版を取得する。
# - 合計ダウンロード量は 約51GB のため、初回起動に時間がかかる。
# ============================================================================

# ============================================================================
# 【TOKEN 設定エリア】
# civitai / HuggingFace のプライベート（early access 等）モデルを
# ダウンロードする場合のみ必要。通常の公開モデルなら空のままで OK。
#
# 方法A（推奨）: vast.ai コンソール → Account Settings、またはテンプレートの
#   Environment Variables に CIVITAI_TOKEN / HF_TOKEN を設定する。
#   スクリプトは環境変数を自動で読み込むため、下の記入欄は空でよい。
#
# 方法B: 下の変数に直接トークンを記入する
#   （※ファイル共有時にトークンが漏れないよう注意）
CIVITAI_TOKEN="${CIVITAI_TOKEN:-}"
HF_TOKEN="${HF_TOKEN:-}"
# ============================================================================

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI

# Packages are installed after nodes so we can fix them...

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(
    # z-tipo (TIPO) 用: llama-cpp-python は CUDA 対応 prebuilt wheel を明示指定
    "llama-cpp-python --prefer-binary --no-cache-dir --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cu121"
)

# ローカルと同じカスタムノード + vast.ai 用に追加したノード
NODES=(
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"   # pysssss (comfyui-custom-scripts)
    "https://github.com/rgthree/rgthree-comfy"                  # rgthree
    "https://github.com/KohakuBlueleaf/z-tipo-extension"        # z-tipo (TIPO / DanTagGen)
    "https://github.com/MoonGoblinDev/Civicomfy"                # サンプルにあったもの
    "https://github.com/KLL535/ComfyUI_PNGInfo_Sidebar"         # サンプルにあったもの
)

WORKFLOWS=(

)

CHECKPOINT_MODELS=(
)

UNET_MODELS=(
)

DIFFUSION_MODELS=(
)

LORA_MODELS=(
    # Dramatic Lighting Slider [Pony, Illustrious] v1.0 (civitai model 1105685)
    "https://civitai.com/api/download/models/1242203"
    # SPO-SDXL_4k-p_10ep_LoRA_webui v1.0 (civitai model 510261)
    "https://civitai.com/api/download/models/567119"
    # MYRHA-Ψ00 v1.0 (civitai model 2122378)
    "https://civitai.com/api/download/models/2400838"
    # Dynamic Poses slider PONYXL — Illustrious/NoobAI 版 (civitai model 438059)
    "https://civitai.com/api/download/models/1607510"
    # [Anima & SDXL] Artist Style: ashima/アシマ v1.0 (civitai model 1874587)
    "https://civitai.com/api/download/models/2121778"
    # HL's Styles - WAI | ILLUSTRIOUS — WSSKX - Aesthetic Bloom (civitai model 1116233)
    "https://civitai.com/api/download/models/1261280"
)

VAE_MODELS=(

)

TEXT_ENCODER_MODELS=(

)

EMBEDDINGS_MODELS=(
    # Lazy Embeddings (civitai model 1302719)
    "https://civitai.com/api/download/models/1550840"   # lazyhand v1.0
    "https://civitai.com/api/download/models/2121199"   # lazyneg
    "https://civitai.com/api/download/models/1601074"   # lazynsfw
    "https://civitai.com/api/download/models/1833157"   # lazypos
    "https://civitai.com/api/download/models/1667494"   # lazyreal
)

ESRGAN_MODELS=(
)

CONTROLNET_MODELS=(
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_nodes
    provisioning_get_pip_packages
    provisioning_get_files \
        "${COMFYUI_DIR}/models/checkpoints" \
        "${CHECKPOINT_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/unet" \
        "${UNET_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/diffusion_models" \
        "${DIFFUSION_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/lora" \
        "${LORA_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/controlnet" \
        "${CONTROLNET_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/vae" \
        "${VAE_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/text_encoders" \
        "${TEXT_ENCODER_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/embeddings" \
        "${EMBEDDINGS_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/esrgan" \
        "${ESRGAN_MODELS[@]}"
    provisioning_print_end
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
            sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
            pip install ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="${COMFYUI_DIR}custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull )
                if [[ -e $requirements ]]; then
                   pip install --no-cache-dir -r "$requirements"
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
            if [[ -e $requirements ]]; then
                pip install --no-cache-dir -r "${requirements}"
            fi
        fi
    done
}

function provisioning_get_files() {
    if [[ -z $2 ]]; then return 1; fi
    
    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

function provisioning_has_valid_hf_token() {
    [[ -n "$HF_TOKEN" ]] || return 1
    url="https://huggingface.co/api/whoami-v2"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_has_valid_civitai_token() {
    [[ -n "$CIVITAI_TOKEN" ]] || return 1
    url="https://civitai.com/api/v1/models?hidden=1&limit=1"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $CIVITAI_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    if [[ -n $HF_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
    elif 
        [[ -n $CIVITAI_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"
    fi
    if [[ -n $auth_token ]];then
        wget --header="Authorization: Bearer $auth_token" -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    else
        wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    fi
}

# Allow user to disable provisioning if they started with a script they didn't want
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
