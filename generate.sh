#!/bin/bash
# Generates the release assets in output/ (from any directory, with restv2 in the environment, i.e. its
# thisREST.sh sourced):
#   ./generate.sh
# - <project>.root: all the readouts of each <project>/<project>.yaml (every readout section, e.g. the planes
#   of a detector), generated with REST_Detector_GenerateReadouts from the directory of the YAML (its decoding
#   files are relative to it), with the overlaps checked; decoding "nominal_decoding".
# - <readout name>_fibres.xml: for a fibre readout, the placements of its fibres, an entity of the GDML of
#   the simulation (TRestFibreReadout::WriteGDMLPlacements).
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
out="$root/output"
rm -rf "$out"
mkdir -p "$out"

for yaml in "$root"/*/*.yaml; do
    name=$(basename "$yaml" .yaml)
    echo "== $name"
    # -e and gSystem->Exit: the exit code is the value of the macro (a bare call is not run by restRoot)
    call="REST_Detector_GenerateReadouts(\"$name.yaml\", \"$out/$name.root\", \"nominal_decoding\", true)"
    (cd "$(dirname "$yaml")" && restRoot -b -q -e "gSystem->Exit($call);")
done

echo "Assets in $out:"
ls -l "$out"
