import Base: zero, one, iszero, isone, isinf, isnan, isfinite, isinteger,
             (-), signbit, sign, abs, flipsign, copysign, frexp, ldexp

zero(::Type{Double{T,E}}) where {T<:SysFloat,E<:Emphasis} = Double(E, zero(T), zero(T))
zero(x::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = Double(E, zero(T), zero(T))
one(::Type{Double{T,E}}) where {T<:SysFloat,E<:Emphasis} = Double(E, one(T), zero(T))
one(x::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = Double(E, one(T), zero(T))
two(::Type{Double{T,E}}) where {T<:SysFloat,E<:Emphasis} = Double(E, two(T), zero(T))
two(x::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = Double(E, two(T), zero(T))
half(::Type{Double{T,E}}) where {T<:SysFloat,E<:Emphasis} = Double(E, half(T), zero(T))
half(x::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = Double(E, half(T), zero(T))

@inline iszero(x::Double{T,E}) where {T,E} = x === zero(Double{T,E})
@inline isone(x::Double{T,E}) where {T,E} = x === one(Double{T,E})
@inline isinf(x::Double{T,E}) where {T,E} = isinf(hi(x))
@inline isnan(x::Double{T,E}) where {T,E} = isnan(hi(x))
@inline isfinite(x::Double{T,E}) where {T,E} = isfinite(hi(x))
@inline notfinite(x::T) where T<:SysFloat = isinf(x) || isnan(x)
@inline notfinite(x::Double{T,E}) where {T,E} = notfinite(hi(x))
@inline isinteger(x::Double{T,E}) where {T,E} = isinteger(lo(x)) && isinteger(hi(x)) # handle 0

@inline signbit(a::Double{T,E}) where {T,E} = signbit(a.hi)
@inline sign(a::Double{T,E}) where {T,E} = sign(a.hi)
@inline abs(a::Double{T,E}) where {T,E} = signbit(a) ? Double(E, -a.hi, -a.lo) : a
@inline (-)(a::Double{T,E}) where {T,E} = Double(E, -a.hi, -a.lo)

@inline function flipsign(x::Double{T,E}, y::T) where {T<:SysFloat, E<:Emphasis}
    signbit(y) ? -x : x
end
@inline function flipsign(x::Double{T,E}, y::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    signbit(y) ? -x : x
end

@inline function copysign(x::Double{T,E}, y::T) where {T<:SysFloat, E<:Emphasis}
    signbit(y) ? -(abs(x)) : abs(x)
end
@inline function copysign(x::Double{T,E}, y::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    signbit(y) ? -(abs(x)) : abs(x)
end


function ldexp(x::Double{T,E}, exponent::I) where {T,E,I<:Integer}
    return Double(E, ldexp(hi(x), exponent), ldexp(lo(x), exponent))
end

function frexp(::Type{E}, x::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    frhi, exphi = frexp(hi(x))
    frlo, explo = frexp(lo(x))
    return E, frhi, exphi, frlo, explo
end

function ldexp(::Type{E}, frhi::T, exphi::I, frlo::T, explo::I) where {T<:SysFloat, I<:Integer, E<:Emphasis}
    zhi = ldexp(frhi, exphi)
    zlo = ldexp(frlo, explo)
    return Double(E, zhi, zlo)
end

function frexp(x::Double{T,E}) where {T,E}
    frhi, exphi = frexp(hi(x))
    frlo, explo = frexp(lo(x))
    return frhi, exphi, frlo, explo
end

function ldexp(frhi::T, exphi::I, frlo::T, explo::I) where {T<:SysFloat, I<:Integer}
    zhi = ldexp(frhi, exphi)
    zlo = ldexp(frlo, explo)
    return Double(EMPHASIS, zhi, zlo)
end

function mulby2(x::Double{T,E}) where {T,E}
    zhi = two(T) * hi(x)
    zlo = two(T) * lo(x)
    return Double(E, zhi, zlo)
end

function divby2(x::Double{T,E}) where {T,E}
    zhi = half(T) * hi(x)
    zlo = half(T) * lo(x)
    return Double(E, zhi, zlo)
end

function mulby2pow(x::Double{T,E}, twopow::I) where {T,E,I<:Integer}
    frhi, exphi, frlo, explo = frexp(x)
    exphi += twopow
    explo += twopow
    return ldexp(E, frhi, exphi, frlo, explo)
end

function divby2pow(x::Double{T,E}, twopow::I) where {T,E,I<:Integer}
    frhi, exphi, frlo, explo = frexp(x)
    exphi -= twopow
    explo -= twopow
    return ldexp(E, frhi, exphi, frlo, explo)
end
