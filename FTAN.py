import glob
import os

from FTANos import FTANos

input_dir = "SAC_files"
output_dir = "FTAN_curves"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

sac_files = glob.glob(os.path.join(input_dir, "*.sac"))

for sac_file in sac_files:
    ftan = FTANos(
        filename=sac_file,
        filetype="SAC",
    )

    ftan.plot_FTAN()

    base_name = os.path.splitext(os.path.basename(sac_file))[0]
    output_image_path = os.path.join(output_dir, base_name)
    ftan.filename = output_image_path
