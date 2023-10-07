using Pkg
Pkg.activate(".")
using Glob
using DICOM
using DataFrames
using CSV
using Pipe
using Statistics

filenames = glob("DICOM/*")
# filenames = glob("/Users/eduard/Neurochirurgie/Boston/CNOC/FELIX Deep Learning/Non-anonymized, only T2 SAG and TRA n = 155/*")

function get_metadata(filename)
    dcm_data = dcm_parse(filename)
    slice_thickness = dcm_data[(0x0018, 0x0050)]
    voxel_size = dcm_data[(0x0028, 0x0030)][1] # pixel spacing    
    manufacturer = dcm_data[(0x0008, 0x0070)]
    return slice_thickness, voxel_size, manufacturer
end

ds = DataFrame(filename=filenames,
    MRI_ID=Int.(zeros(length(filenames))),
    axial_slice_thickness=zeros(length(filenames)),
    axial_voxel_size=zeros(length(filenames)),
    manufacturer=fill("Unknown", length(filenames)),
    sagittal_slice_thickness=zeros(length(filenames)),
    sagittal_voxel_size=zeros(length(filenames)),
    )

for idx = eachindex(ds.MRI_ID)
    ds.MRI_ID[idx] = idx
    sagittals = glob("$(ds.filename[idx])/Sagittal/*.dcm")[1]
    axials = glob("$(ds.filename[idx])/Axial/*.dcm")[1]
    ds.axial_slice_thickness[idx], ds.axial_voxel_size[idx], ds.manufacturer[idx] = get_metadata(axials)
    ds.sagittal_slice_thickness[idx], ds.sagittal_voxel_size[idx], _ = get_metadata(sagittals)
end

# This is to later get link on the MRI_ID with the actual data
# lookup = @pipe CSV.File("data.csv") |> DataFrame(_)
# for row = eachrow(lookup)
#     mri_id = @pipe row.filename |> split(_, "/")[3] |> split(_, "_")[1] |> match(r"PT(\d{3})", _).captures[1] |> parse(Int, _)
# end
