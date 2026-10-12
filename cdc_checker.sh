#!/usr/bin/bash

usage() {
    echo "Usage: $0 [--sv] [-t|--top TOP_MODULE] [-d|--dir FILE_DIRECTORY] [-c|--constr CONSTRAINT_FILE] [-p|--constr_dir CONSTRAINT_DIRECTORY] [-o|--output OUTPUT_FILE]"
    echo "  --sv                                        Specify whether the design contains any systemverilog files."
    echo "  -t, --top           TOP_MODULE              Specify the name of top module."
    echo "  -d, --dir           FILE_DIRECTORY          Specify the path to the design."
    echo "  -c, --constr        CONSTRAINT_FILE         Specify the name of constraint file. Must be of the format .SDC or .XDC"
    echo "  -p, --constr_dir    CONSTRAINT_DIRECTORY    Specify the path to constraint file."
    echo "  -o, --output        OUTPUT_FILE             Specify the name of output file which will be automatically stored with the design. (Optional)"
    echo "  -h, --help                                  Display this message."

    exit 1
}

SHORT="t:d:c:p:ho:"
LONG="sv,top:,dir:,constr:,constr_dir:,help,output:"

PARSED=$(getopt --options=$SHORT --longoptions=$LONG --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1
fi

eval set --"$PARSED"

TOP_MODULE=""
CONSTR=""
DIR=""
OUTPUT_FILE=""
file_format="v"
CONSTR_DIR=""

while true; do
    case "$1" in
        --sv)
            file_format="sv"
            shift
            ;;
        -t|--top)
            TOP_MODULE="$2"
            shift 2
            ;;
        -d|--dir)
            DIR="$2"
            shift 2
            ;;
        -c|--constr)
            CONSTR="$2"
            shift 2
            ;;
        -p|--constr_dir)
            CONSTR_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming Error"
            exit 3
            ;;
    esac
done

echo "TOP MODULE: $TOP_MODULE"
echo "DIRECTORY: $DIR"


if [[ -z "$TOP_MODULE" ]]; then
    echo "-t|--top option is necessary and requires exactly 1 argument"
    usage
fi
if [[ -z "$DIR" ]]; then
    echo "-d|--dir option is necessary and requires exactly 1 argument"
    usage
fi
if [[ -z "$CONSTR" ]]; then
    echo "-c|--constr option is necessary and requires exactly 1 argument"
    usage
fi

if [[ -z "$CONSTR_DIR" ]]; then
    CONSTR_DIR="$DIR"
fi

echo "CONSTRAINT FILE: $CONSTR_DIR/$CONSTR"

if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE=$TOP_MODULE"_cdc_report.json"
fi

OUTPUT_DIR="$DIR/../CDC_REPORTS"
echo "OUTPUT FILE: $OUTPUT_DIR/$OUTPUT_FILE"

chmod -R g+w $DIR
[ ! -d $OUTPUT_DIR ] && mkdir "$OUTPUT_DIR"

FILESET="$DIR/*.$file_format"
echo "FILESET: $FILESET"

uv run rtl-buddy-cdc lint \
    --top $TOP_MODULE \
    --sdc $CONSTR_DIR/$CONSTR \
    --format json \
    --output $OUTPUT_DIR/$OUTPUT_FILE \
    $FILESET


echo "CDC checking done!"

if grep -i -q "error" $OUTPUT_DIR/$OUTPUT_FILE; then
    echo "The design contains some CDC violations!"
else
    echo "The design is CDC Safe!"
fi

echo "For debugging/viewing reports, check $OUTPUT_DIR/$OUTPUT_FILE"