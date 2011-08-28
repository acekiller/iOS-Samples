/*
 
 File: Matrix4x4.c
 
 Abstract: Functions to do simple 4x4 matrix calculations, including 
 matrix*matrix and matrix*vector.
 
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

#include "Matrix4x4.h"

/*
 NOTE: These functions are created for your convenience but the matrix algorithms 
 are not optimized. You are encouraged to do additional research on your own to 
 implement a more robust numerical algorithm.
*/

// GL matrix is column-major

void MatrixMultMatrix(const float* M1, const float* M2, float* Mout)
{
	float res[16];
	res[0]  = M1[0]*M2[0]  + M1[4]*M2[1]  + M1[8]*M2[2]  + M1[12]*M2[3];
	res[4]  = M1[0]*M2[4]  + M1[4]*M2[5]  + M1[8]*M2[6]  + M1[12]*M2[7];
	res[8]  = M1[0]*M2[8]  + M1[4]*M2[9]  + M1[8]*M2[10] + M1[12]*M2[11];
	res[12] = M1[0]*M2[12] + M1[4]*M2[13] + M1[8]*M2[14] + M1[12]*M2[15];
	
	res[1]  = M1[1]*M2[0]  + M1[5]*M2[1]  + M1[9]*M2[2]  + M1[13]*M2[3];
	res[5]  = M1[1]*M2[4]  + M1[5]*M2[5]  + M1[9]*M2[6]  + M1[13]*M2[7];
	res[9]  = M1[1]*M2[8]  + M1[5]*M2[9]  + M1[9]*M2[10] + M1[13]*M2[11];
	res[13] = M1[1]*M2[12] + M1[5]*M2[13] + M1[9]*M2[14] + M1[13]*M2[15];
	
	res[2]  = M1[2]*M2[0]  + M1[6]*M2[1]  + M1[10]*M2[2]  + M1[14]*M2[3];
	res[6]  = M1[2]*M2[4]  + M1[6]*M2[5]  + M1[10]*M2[6]  + M1[14]*M2[7];
	res[10] = M1[2]*M2[8]  + M1[6]*M2[9]  + M1[10]*M2[10] + M1[14]*M2[11];
	res[14] = M1[2]*M2[12] + M1[6]*M2[13] + M1[10]*M2[14] + M1[14]*M2[15];
	
	res[3]  = M1[3]*M2[0]  + M1[7]*M2[1]  + M1[11]*M2[2]  + M1[15]*M2[3];
	res[7]  = M1[3]*M2[4]  + M1[7]*M2[5]  + M1[11]*M2[6]  + M1[15]*M2[7];
	res[11] = M1[3]*M2[8]  + M1[7]*M2[9]  + M1[11]*M2[10] + M1[15]*M2[11];
	res[15] = M1[3]*M2[12] + M1[7]*M2[13] + M1[11]*M2[14] + M1[15]*M2[15];
	
	int i;
	for (i=0; i<16; i++)
		Mout[i] = res[i];
}	

void MatrixMultVector(const float* M, const float* v, float* vout, int voutIs4D)
{
	float res[4];
	res[0] = M[0]*v[0] + M[4]*v[1] + M[ 8]*v[2] + M[12]*v[3];
	res[1] = M[1]*v[0] + M[5]*v[1] + M[ 9]*v[2] + M[13]*v[3];
	res[2] = M[2]*v[0] + M[6]*v[1] + M[10]*v[2] + M[14]*v[3];
	res[3] = M[3]*v[0] + M[7]*v[1] + M[11]*v[2] + M[15]*v[3];
	
	if (voutIs4D) {
		vout[0] = res[0];
		vout[1] = res[1];
		vout[2] = res[2];
		vout[3] = res[3];
	}
	else {
		vout[0] = res[0] / res[3];
		vout[1] = res[1] / res[3];
		vout[2] = res[2] / res[3];
	}	
}


