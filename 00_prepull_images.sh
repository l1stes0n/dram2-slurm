#!/bin/bash
#
# download SIF blobs directly from the registries

CACHE=$HOME/.nextflow/singularity
REG=https://community.wave.seqera.io
AUTH=https://cerbero.seqera.io/auth/token

nextflow plugin install nf-schema@2.1.1

mkdir -p "$CACHE"
cd "$CACHE" || exit 1

wave() {  # <repo> <ref> <cache-file>
    [ -s "$3" ] && { echo "have $3"; return; }
    local token manifest layer digest size
    token=$(curl -fsSL "$AUTH?service=community.wave.seqera.io&scope=repository:$1:pull" \
        | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
    manifest=$(curl -fsSL -H "Authorization: Bearer $token" \
        -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
        "$REG/v2/$1/manifests/$2")
    layer=$(printf '%s' "$manifest" | sed -n 's/.*"layers":\(\[[^]]*\]\).*/\1/p')
    digest=$(printf '%s' "$layer" | grep -oE 'sha256:[a-f0-9]{64}' | head -n 1)
    size=$(printf '%s' "$layer" | grep -oE '"size":[0-9]+' | head -n 1 | cut -d: -f2)
    echo "pull $3 ($((size / 1048576)) MB)"
    curl -fL --retry 3 -H "Authorization: Bearer $token" -o "$3.part" \
        "$REG/v2/$1/blobs/$digest" || exit 1
    mv "$3.part" "$3"
}

wave library/bbmap eecc2d5093684dba community.wave.seqera.io-library-bbmap-eecc2d5093684dba.img
wave library/python_pandas_scikit-bio_hmmer_pruned 0bcae53ff4ef8178 community.wave.seqera.io-library-python_pandas_scikit-bio_hmmer_pruned-0bcae53ff4ef8178.img
wave library/python_pandas_polars_hmmer_pruned 1742d882bc99fed5 community.wave.seqera.io-library-python_pandas_polars_hmmer_pruned-1742d882bc99fed5.img
wave library/dbcan_diamond fbd051caf73e295f community.wave.seqera.io-library-dbcan_diamond-fbd051caf73e295f.img
wave library/python_bokeh_panel_click_pruned 51f8873f5a533b04 community.wave.seqera.io-library-python_bokeh_panel_click_pruned-51f8873f5a533b04.img
wave library/python_bokeh_panel_click_pruned 4c61417bc024049e community.wave.seqera.io-library-python_bokeh_panel_click_pruned-4c61417bc024049e.img

MULTIQC=depot.galaxyproject.org-singularity-multiqc-1.25.1--pyhdfd78af_0.img
if [ ! -s "$MULTIQC" ]; then
    echo "pull $MULTIQC (270 MB)"
    curl -fL --retry 3 -o "$MULTIQC.part" \
        'https://depot.galaxyproject.org/singularity/multiqc:1.25.1--pyhdfd78af_0' || exit 1
    mv "$MULTIQC.part" "$MULTIQC"
fi

