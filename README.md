# rest-common-readouts

The detector readouts shared by the projects of rest-for-physics-toolkit (AlphaCAMM, LiquidO...) for
[restv2](https://github.com/rest-for-physics-toolkit/rest-framework).

Only the sources are in the repository (a directory per project: its YAML and decoding files). The readout
files are the assets of each release (a tag `v*`), so a project reads a fixed version of them by URL, in
`inputFileName` of `TRestDetectorReadoutManager`:

```
https://github.com/rest-for-physics-toolkit/rest-common-readouts/releases/download/<tag>/<asset>
```

restv2 downloads a URL once and keeps it in `$REST_HOME/.rest/download` (it works offline afterwards, e.g. in
the nodes of a cluster).

Part of the shared resources of restv2 (topic `rest-common`):
[rest-common-materials](https://github.com/rest-for-physics-toolkit/rest-common-materials) (Geant4 materials),
[rest-common-transport](https://github.com/rest-for-physics-toolkit/rest-common-transport) (electron transport
tables) and readouts (this repository).

## Catalogue

One file per project, with all its readouts (one entry each in the readout manager, the same file):

| Asset | Readouts (instance names) | Description |
|---|---|---|
| `AlphaCAMM.root` | `AlphaCAMM_Readout` | AlphaCAMM Micromegas, 256 strips per axis, pitch 0.96 mm, plane at z = 0, cathode at z = 90 mm. |
| `TREXDM.root` | `TREXDM_Plane0_Readout`, `TREXDM_Plane1_Readout` | TREX-DM MM4S Micromegas (September 2022, v5), two planes: at z = 160.4 mm (DAQ channels 2-573) and at z = -160.4 mm (578-1149), 256 strips per axis, pitch 0.96 mm, cathode at z = 0 (from the legacy trexdm-readouts, with the DAQ channel of the Y strip 1 corrected). |
| `IAXO.root` | `IAXO_D1_Readout` | IAXO-D1 Micromegas in the IAXOLab, 120 strips per axis, pitch 0.5 mm, rotated 45 degrees, plane at z = -15 mm with a 30 mm drift volume. |
| `LiquidO.root`, `LiquidO_Readout_fibres.xml` | `LiquidO_Readout` | LiquidO fibres (dummy identity decoding, `LiquidO.dec`): a 1500 mm box from z = 0 crossed by fibres along Y (channels 0-5624) and along X (5625-11249), pitch 20 mm, alternated layers 10 mm apart. `LiquidO_Readout_fibres.xml`: the placements of the fibres, an entity of the GDML of the simulation inside the volume of the scintillator. |

The decoding of all of them is `nominal_decoding`:

```yaml
readouts:
  class: "TRestDetectorReadoutManager"
  readouts:
    - {instanceName: "AlphaCAMM_Readout", decodingName: "nominal_decoding",
       inputFileName: "https://github.com/rest-for-physics-toolkit/rest-common-readouts/releases/download/v1.0/AlphaCAMM.root"}
```

TREX-DM, with its two planes (`readout`: the one of the data of the file, e.g. the plane selected by
`TRestRawSignalChannelSelectionProcess`):

```yaml
readouts:
  class: "TRestDetectorReadoutManager"
  readout: "TREXDM_Plane0_Readout"
  readouts:
    - {instanceName: "TREXDM_Plane0_Readout", decodingName: "nominal_decoding",
       inputFileName: "https://github.com/rest-for-physics-toolkit/rest-common-readouts/releases/download/v1.0/TREXDM.root"}
    - {instanceName: "TREXDM_Plane1_Readout", decodingName: "nominal_decoding",
       inputFileName: "https://github.com/rest-for-physics-toolkit/rest-common-readouts/releases/download/v1.0/TREXDM.root"}
```

The fibres of LiquidO in the GDML of its simulation:

```xml
<!DOCTYPE gdml [
<!ENTITY fibres SYSTEM "https://github.com/rest-for-physics-toolkit/rest-common-readouts/releases/download/v1.0/LiquidO_Readout_fibres.xml">
]>
...
<volume name="chamberVolume">
    ...
    &fibres;
</volume>
```

## Generation

With restv2 in the environment (its `thisREST.sh` sourced), `./generate.sh` writes, for each
`<project>/<project>.yaml`, `output/<project>.root` with all its readouts (`REST_Detector_GenerateReadouts`)
and `output/<readout name>_fibres.xml` for a fibre readout, with the geometry overlaps checked (it fails if
there is any). The CI (`.github/workflows/release.yml`) runs it at each push and pull request and attaches the
assets to the release of each tag.

A new readout: a section (`TRestMicromegasReadout`, `TRestGDMLReadout` or `TRestFibreReadout`, with a unique
`name`) in `<project>/<project>.yaml`, and its decoding file; a new project, its directory. A new decoding of
a readout already generated can be added to its file with `REST_Detector_AddDecoding`.

## Release

1. Check the CI of `master` (the artifact `readouts` has the generated files).
2. `git tag v1.1 && git push origin v1.1`: the CI creates the release with the readout files.

## Origin

The TREX-DM readout was converted from
[rest-for-physics/trexdm-readouts](https://github.com/rest-for-physics/trexdm-readouts)
(`readoutsMM4S_2MM_v5.root`, with the DAQ channel of the Y strip 1 corrected: an error of the MM4S
spreadsheet gave it that of the Y strip 29).
