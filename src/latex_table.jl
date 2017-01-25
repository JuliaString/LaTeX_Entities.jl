VER = UInt32(1)

immutable LaTeX_Table{T} <: AbstractEntityTable
    ver::UInt32
    tim::String
    inf::String
    base32::UInt32
    base2c::UInt32
    nam::StrTable{T}
    ind::Vector{UInt16}
    val16::Vector{UInt16}
    ind16::Vector{UInt16}
    val32::Vector{UInt16}
    ind32::Vector{UInt16}
    val2c::Vector{UInt32}
    ind2c::Vector{UInt16}
end
