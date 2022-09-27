---
title: "Intel SIMD Study"
date: 2022-04-22T00:39:23+03:00
draft: false
---

## Optimizing Simple Matrix Multiplication With Intel SIMD

### Abstract

This is a test report about possible performance gains in a simple 4x4 or 8x8
matrix multiplication when using Intel's intrinsic instruction wrappers and SIMD
(Single Instruction Mutiple Data) types.  SIMD intrinsic functions are basically
wrappers for assembly instructions, which can be conveniently used inside a
C-program. Thus we can explore the full power of vectorization and other
techniques taking advantage of the wider datatypes and corresponding methods.

### SIMD: A Brief Introduction

SIMD stands for single instruction multiple data and means exactly that. We
operate on data registers that are wider than those commonly used in programs
and which can hold up to 512-bits of data instead of a maximum of 64-bits. We
get instructions which operate on such registers simultaneously.

Each CPU instruction set has their own corresponding SIMD-instructions.
Different architectures may or may not prowide datatypes with the same sizes. In
this article we concentrate on Intel x86 instruction set and it's corresponding
instrinsics. When we implement something with these teachniques, we are
implementing hardware dependant code, which will not compile for platforms using
different instruction sets such as ARM or RISC-V. However we can implement SIMD
optimizations on top of naive implementations in such a way that the
optimizations are used only if the target platform supports them and otheriwse
we use the naive implementations as fallback and let the compiler optimize them
as best it can.

#### SIMD - Vectors

The first thing we need to understand is that the SIMD registers work as fixed
size vectors. So a `__m128` type is the same as `float[4]` and typecasting
between the two or putting them in a union works.

```c
__m128	xmm;	// A 128-bit register of 4 x float
__m128d	xmm;	// A 128-bit register of 2 x double
__m128i	xmm;	// A 128-bit register of 4 x int32??
__m256	xmm;	// A 256-bit register of 8 x float
__m256d	xmm;	// A 256-bit register of 4 x double
__m256i	xmm;	// A 256-bit register of 4 x int64
```

#### Convenient Unions

In my tests I found a convenient use for unions in the context of SIMD
vectors.

```c
typedef union u_m4x4f
{
	float	n[4][4];
	__m128	xmm[4];
}	t_m4x4f;
```

The `__m128` type is a 128-bit wide register interpreted as a float. In order to
produce a 4x4 matrix, we need 4 such registers. When we declare those registers
inside a union together with a 4x4 array of floats, we can easily access the
values in the matrix without having to do ugly casts.

#### Basic Operations

Let's consider simple addition of elements in two vectors. We could use the
function `_mm_add_ps` to do this.

```
1  2  3  4
+  +  +  +
2  3  4  5
=  =  =  =
2  6  12 20
```

### Vectorization

Vectorization is a method of parallel computation. When working with SIMD-
types, we leverage the fact that we have up to 512-bit (in AVX512 enabled
machines) wide registers which we can operate on. However there are also clear
limitations to this method as will be explored later.

The first bit of important insight we need to establish is where in the process
we actually find the performance gains. Let's consider multiplying two vectors
of floats together.

```c
void mul(float dst[4], float a[4], float b[4])
{
	for (i = 0; i < 4; i++)
	{
		dst[i] = a[i] * b[i];
	}
}
```

Above we iterate over the values and multiply them together. Now let's do the
same with SIMD registers.


```c
__m128 mul(__m128 dst, __m128 a, __m128 b)
{
	return (__mm_mul_ps(a, b);
}
```

Actually the whole function is redundant because the `__mm_mul_ps` itself is the
multiplication function for the whole vector of 4 floats.

So how will this lead to a performance increase? Well multiplying 2 floats
together with the `*` operator will take about the same amount of clock-cycles
as multiplying those 8 floats in the two SIMD registers together. Furthermore we
have even bigger SIMD-registers representing 8 or even 16 floats. If we can
structure our logic such that we do as much parallel computation as possible, we
can get performance gains against a linear algorithm.

It is important to mention that this is exactly what the compiler does as a part
of the optimization steps when you optimize your program with the `-O3` flag.

Futhermore it's worth mentioning that the same logic of vectorization is closely
related to the technique of loop unrolling.

!!!Talk about how parallel vs. linear computing methods partly solve different
problems. For example dot product.

### Matrix Multiplication

#### Naive Implementation

```c
t_m4x4f	m4x4f_mul_naive(t_m4x4f *a, t_m4x4f *b)
{
	t_m4x4f	res;

	for(int i = 0; i < 4; i++)
	{
	    for(int j = 0; j < 4; j++)
		{
	        res.n[i][j] = 0;
	        for(int k = 0; k < 4; k++)
			{
	            res.n[i][j] += a->n[i][k] * b->n[k][j];
	        }
	    }
	}
	return (res);
}
```

#### Simple Implementation Using SIMD

```c
t_m4x4f	m4x4f_mul_direct_no_unroll(t_m4x4f *a, t_m4x4f *b)
{
	t_m4x4f	res;
	__m128	xmm[4];
	uint8_t	i;

	i = 0;
	while (i < 4)
	{
		xmm[0] = _mm_broadcast_ss(&a->n[i][0]);
		xmm[1] = _mm_broadcast_ss(&a->n[i][1]);
		xmm[2] = _mm_broadcast_ss(&a->n[i][2]);
		xmm[3] = _mm_broadcast_ss(&a->n[i][3]);
		res.xmm[i] = _mm_mul_ps(xmm[0], b->xmm[0]);
		res.xmm[i] = _mm_fmadd_ps(xmm[1], b->xmm[1], res.xmm[i]);
		res.xmm[i] = _mm_fmadd_ps(xmm[2], b->xmm[2], res.xmm[i]);
		res.xmm[i] = _mm_fmadd_ps(xmm[3], b->xmm[3], res.xmm[i]);
		i++;
	}
	return (res);
}
```

### Test and Results

#### Test Setup

#### Results

#### Conclusions

### Resources

https://stackoverflow.blog/2020/07/08/improving-performance-with-simd-intrinsics-in-three-use-cases/



