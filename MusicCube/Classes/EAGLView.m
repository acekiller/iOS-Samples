/*
 
 File: EAGLView.m
 
 Abstract: A visual representation of our sound stage
 
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */


/*
 In our sound stage, the cube represents an omnidirectional sound source, and the teapot represents a sound listener.
 The four modes in the application shows how the sound volume and balance will change based on the position of the omnidirectional sound source 
 and the position and rotation of the listener:
 1. Constant sound
 2. Sound variates corresponding to the listener's position changes relative to the source
 3. Sound variates corresponding to the listener's rotation changes relative to the source
 4. Sound variates corresponding to the listener's position and rotation changes relative to the source
*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "teapot.h"

#define USE_DEPTH_BUFFER	1

#define kInnerCircleRadius	1.0
#define kOuterCircleRadius	1.1

#define kTeapotScale		1.8
#define kCubeScale			0.12
#define kButtonScale		0.1

#define kButtonLeftSpace	1.1

#define	DegreesToRadians(x) ((x) * M_PI / 180.0)
#define	RadiansToDegrees(x) ((x) * 180.0 / M_PI)

// A class extension to declare private methods
@interface EAGLView ()

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

- (void) buildCircleVertices:(GLfloat*)vertices withNumOfSegments:(GLint)segments radius:(GLfloat)radius;
- (void) loadTexture:(NSString *)name;

@end


@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = TRUE;
		
		mode = 1;
		
		// create vertex arrays for the circle paths
		[self buildCircleVertices:innerCircleVertices withNumOfSegments:kCircleSegments radius:kInnerCircleRadius];
		[self buildCircleVertices:outerCircleVertices withNumOfSegments:kCircleSegments radius:kOuterCircleRadius];
		
		// load textures
		NSString* textureName[5] = { @"speaker.png", @"nums.png", @"info.png", @"instr.png", @"description.png" };		
		glGenTextures(5, texture);
		
		int i;
		for (i=0; i<5; i++) {
			glBindTexture(GL_TEXTURE_2D, texture[i]);
			[self loadTexture:textureName[i]];
		}
		glBindTexture(GL_TEXTURE_2D, 0);	
    }
    return self;
}

# pragma mark Init

- (void)buildCircleVertices:(GLfloat*)vertices withNumOfSegments:(GLint)segments radius:(GLfloat)radius
{
	GLint count=0;
	for (GLfloat i = 0; i < 360.0f; i += 360.0f/segments)
	{
		vertices[count++] = 0;									//x
		vertices[count++] = (cos(DegreesToRadians(i))*radius);	//y
		vertices[count++] = (sin(DegreesToRadians(i))*radius);	//z
	}
}

- (void) setTeapotMaterial
{
	const GLfloat			lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
	const GLfloat			lightDiffuse[] = {0.2, 0.7, 0.2, 1.0};
	const GLfloat			matAmbient[] = {0.4, 0.8, 0.4, 1.0};
	const GLfloat			matDiffuse[] = {1.0, 1.0, 1.0, 1.0};	
	const GLfloat			matSpecular[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			lightPosition[] = {0.0, 0.0, 1.0, 0.0}; 
	const GLfloat			lightShininess = 100.0;
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition); 			
	glShadeModel(GL_SMOOTH);
}

- (void)loadTexture:(NSString *)name
{
	CGImageRef image = [UIImage imageNamed:name].CGImage;
	CGContextRef texContext;
	GLubyte* bytes = nil;	
	size_t	width, height;
	
	if (image) {
		width = CGImageGetWidth(image);
		height = CGImageGetHeight(image);
		
		bytes = (GLubyte*) calloc(width*height*4, sizeof(GLubyte));
		// Uses the bitmatp creation function provided by the Core Graphics framework. 
		texContext = CGBitmapContextCreate(bytes, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
		// After you create the context, you can draw the image to the context.
		CGContextDrawImage(texContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
		// You don't need the context at this point, so you need to release it to avoid memory leaks.
		CGContextRelease(texContext);
		
		// setup texture parameters
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, bytes);
		free(bytes);
	}
}

# pragma mark Draw

- (void)drawCircle:(GLfloat*)vertices withNumOfSegments:(GLint)segments
{
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glVertexPointer (3, GL_FLOAT, 0, vertices); 
	
	glPushMatrix();
	glColor4f(0.2f, 0.7f, 0.2f, 1.0f);
	glDrawArrays (GL_LINE_LOOP, 0, segments);
	glPopMatrix();
	
	glDisableClientState(GL_VERTEX_ARRAY);
}

- (void)drawTeapot
{
	int	start = 0, i = 0;
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_NORMALIZE);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	
	glVertexPointer(3 ,GL_FLOAT, 0, teapot_vertices);
	glNormalPointer(GL_FLOAT, 0, teapot_normals);
	
	if (!showDesc) rot -= 1.0f;
	GLfloat radius = (kOuterCircleRadius + kInnerCircleRadius) / 2.;
	GLfloat teapotPos[3] = {0.0f, cos(DegreesToRadians(rot))*radius, sin(DegreesToRadians(rot))*radius};
	
	glPushMatrix();
	glLoadIdentity();
	
	// move clockwise along the circle
	glTranslatef(teapotPos[0], teapotPos[1], teapotPos[2]);
	glScalef(kTeapotScale, kTeapotScale, kTeapotScale);
	
	// add rotation;
	GLfloat rotYInRadians;
	if (mode == 2 || mode == 4)
		// in mode 2 and 4, the teapot (listener) always faces to one direction
		rotYInRadians = 0.0f;
	else
		// in mode 1 and 3, the teapot (listener) always faces to the cube (sound source)
		rotYInRadians = atan2(teapotPos[2]-cubePos[2], teapotPos[1]-cubePos[1]);
	
	glRotatef(-90.0f, 0, 0, 1); //we want to display in landscape mode
	glRotatef(RadiansToDegrees(rotYInRadians), 0, 1, 0);
	
	// draw the teapot
	while(i < num_teapot_indices) {
		if(teapot_indices[i] == -1) {
			glDrawElements(GL_TRIANGLE_STRIP, i - start, GL_UNSIGNED_SHORT, &teapot_indices[start]);
			start = i + 1;
		}
		i++;
	}
	if(start < num_teapot_indices)
		glDrawElements(GL_TRIANGLE_STRIP, i - start - 1, GL_UNSIGNED_SHORT, &teapot_indices[start]);
	
	glPopMatrix();
	
	glDisable(GL_LIGHTING);
	glDisable(GL_LIGHT0);
	glDisable(GL_NORMALIZE);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	
	// update playback
	playback.listenerPos = teapotPos; //listener's position
	playback.listenerRotation = rotYInRadians - M_PI; //listener's rotation in Radians
}

-(void)drawCube
{	
	// simple cube data
	// our sound source is omnidirectional, adjust the vertices 
	// so that speakers in textures point to all different directions
	const GLfloat cubeVertices[6][12] = {
		{ 1,-1, 1, -1,-1, 1,  1, 1, 1, -1, 1, 1 },
		{ 1, 1, 1,  1,-1, 1,  1, 1,-1,  1,-1,-1 },
		{-1, 1,-1, -1,-1,-1, -1, 1, 1, -1,-1, 1 },
		{ 1, 1, 1, -1, 1, 1,  1, 1,-1, -1, 1,-1 },
		{ 1,-1,-1, -1,-1,-1,  1, 1,-1, -1, 1,-1 },
		{ 1,-1, 1, -1,-1, 1,  1,-1,-1, -1,-1,-1 },
	};
	
	const GLfloat cubeColors[6][4] = {
		{1, 0, 0, 1}, {0, 1, 0, 1}, {0, 0, 1, 1}, {1, 1, 0, 1}, {0, 1, 1, 1}, {1, 0, 1, 1},
	};
	
	const GLfloat cubeTexCoords[8] = {
		1, 0,  1, 1,  0, 0,  0, 1,
	};
	
	glBindTexture(GL_TEXTURE_2D, texture[0]);
	
	if (!showDesc) cubeRot += 3;
	
	glPushMatrix();
	glLoadIdentity();
	glTranslatef(cubePos[0], cubePos[1], cubePos[2]); 
	glScalef(kCubeScale, kCubeScale, kCubeScale);
	
	if (mode <= 2)
		// origin of the teapot is at its bottom, but 
		// origin of the cube is at its center, so move up a unit to put the cube on surface
		// we'll pass the bottom of the cube (cubePos) to the playback
		glTranslatef(1.0f, 0.0f, 0.0f);
	else
		// in mode 3 and 4, simply move up the cube a bit more to avoid colliding with the teapot
		glTranslatef(4.5f, 0.0f, 0.0f);
	
	// rotate around to simulate the omnidirectional effect
	glRotatef(cubeRot, 1, 0, 0);
	glRotatef(cubeRot, 0, 1, 1);
	
	glTexCoordPointer(2, GL_FLOAT, 0, cubeTexCoords);
	int f;
	for (f = 0; f < 6; f++) {
		glColor4f(cubeColors[f][0], cubeColors[f][1], cubeColors[f][2], cubeColors[f][3]);
		glVertexPointer(3, GL_FLOAT, 0, cubeVertices[f]);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	
	glPopMatrix();
	
	glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)drawModes
{
	glBindTexture(GL_TEXTURE_2D, texture[1]);
	
	const GLfloat buttonVertices[] = {
		-1,-1,0,  1,-1,0, -1, 1,0,  1, 1,0
	};
	
	// numbers 1-4 are stored in a sprite sheet
	// in the first row, numbers are shown as unselected
	const GLfloat buttonNotSelectedTexCoords[4][8] = {
		{0.25, 0.5,   0.25, 0,   0,    0.5,   0,    0}, //1
		{0.5,  0.5,   0.5,  0,   0.25, 0.5,   0.25, 0}, //2
		{0.75, 0.5,   0.75, 0,   0.5,  0.5,   0.5,  0}, //3
		{1,    0.5,   1,    0,   0.75, 0.5,   0.75, 0}, //4
	};
	
	// in the second row, numbers are shown as seleted
	const GLfloat buttonSelectedTexCoords[4][8] = {
		{0.25, 1,   0.25, 0.5,   0,    1,   0,    0.5}, //1
		{0.5,  1,   0.5,  0.5,   0.25, 1,   0.25, 0.5}, //2
		{0.75, 1,   0.75, 0.5,   0.5,  1,   0.5,  0.5}, //3
		{1,    1,   1,    0.5,   0.75, 1,   0.75, 0.5}, //4
	};
	
	glVertexPointer(3, GL_FLOAT, 0, buttonVertices);
	
	// draw each button in its right mode (selected/unselected)
	int i;
	for (i=0; i<4; i++) 
	{
		glPushMatrix();
		glLoadIdentity();
		glTranslatef(-1.0f, 1.5f-kButtonLeftSpace, 0.0f); //move to the bottom-left corner (in landscape)
		glScalef(kButtonScale, kButtonScale, 1.0f);
		glTranslatef(1.0f, -1.0f-2*i, 0.0f); //move to the current grid
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		if (mode == i+1) //is currently selected
			glTexCoordPointer(2, GL_FLOAT, 0, buttonSelectedTexCoords[i]);
		else
			glTexCoordPointer(2, GL_FLOAT, 0, buttonNotSelectedTexCoords[i]);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}
	
	glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)drawInstr
{	
	const GLfloat quadVertices[] = {
		-1,-1,0,  1,-1,0, -1, 1,0,  1, 1,0
	};
	
	const GLfloat quadTexCoords[] = {
		 1, 1,  1, 0,  0, 1,  0, 0 
	};	
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	
	glVertexPointer(3, GL_FLOAT, 0, quadVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, quadTexCoords);
	
	// draw the info button
	glBindTexture(GL_TEXTURE_2D, texture[2]);
	glPushMatrix();
	glTranslatef(-1.0f, 1.5f, 0.0f); //move to the bottom-left corner (in landscape)
	glScalef(0.05f, 0.05f, 1.0f);
	glTranslatef(2.0f, -1.5f, 0.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	// draw text
	glBindTexture(GL_TEXTURE_2D, texture[3]);
	glPushMatrix();
	glTranslatef(-1.0f, 1.3f, 0.0f); //move to the bottom-left corner (in landscape)
	glScalef(0.1f, 0.4f, 1.0f);
	glTranslatef(1.0f, -1.0f, 0.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	glBindTexture(GL_TEXTURE_2D, 0);
	
	if (showDesc)
	{
		// put description in front of everything
		const GLfloat descVertices[] = {
			-1,-1,10,  1,-1,10, -1, 1,10,  1, 1,10
		};
		
		GLfloat w = 480./512., h = 198./256.;
		const GLfloat descTexCoords[] = {
			w, h,  w, 0,  0, h,  0, 0 
		};

		glVertexPointer(3, GL_FLOAT, 0, descVertices);
		glTexCoordPointer(2, GL_FLOAT, 0, descTexCoords);
		
		// draw transparent gray in background
		glColor4f(0.05f, 0.05f, 0.05f, 0.8f);
		glPushMatrix();
		glTranslatef(0.0f, 0.0f, -0.1f);
		glScalef(1.0f, 1.5f, 1.0f);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		
		// draw description text on top
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glBindTexture(GL_TEXTURE_2D, texture[4]);
		glPushMatrix();
		glScalef(198./320., 1.5f, 1.0f);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		
		glBindTexture(GL_TEXTURE_2D, 0);
	}
}	

- (void)drawView {
    
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// start drawing 3D objects
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, -10.0f, 10.0f);
	// tranform the camara for a better view
	glTranslatef(0.07f, 0.0f, 0.0f);
	glRotatef(-30.0f, 0.0f, 1.0f, 0.0f);
	glMatrixMode(GL_MODELVIEW);
	
	[self drawCircle:innerCircleVertices withNumOfSegments:kCircleSegments];
	[self drawCircle:outerCircleVertices withNumOfSegments:kCircleSegments];
	[self drawTeapot];
	
	// enable GL states for texturing
	// this includes cube and 2D instructions and buttons
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	[self drawCube];
	
	if (!showDesc) glDisable(GL_DEPTH_TEST);
	
	// start drawing 2D instructions and buttons
	glMatrixMode(GL_PROJECTION); 
    glLoadIdentity();
    glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, -10.0f, 10.0f);
	glMatrixMode(GL_MODELVIEW);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	[self drawModes];
	[self drawInstr];
	glDisable(GL_BLEND);
	
	//disable GL states for texturing
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	
	if (showDesc) glDisable(GL_DEPTH_TEST);

    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
	[self setTeapotMaterial];
    [self drawView];
	if (!showDesc) [playback startSound];
}

- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
	glViewport(0, 0, backingWidth, backingHeight);
	
	// initialize playback
	// the sound source (cube) starts at the center
	playback.sourcePos[0] = playback.sourcePos[1] = playback.sourcePos[2] = 0;
	// the linster (teapot) starts on the left side (in landscape)
	playback.listenerPos[0] = 0;
	playback.listenerPos[1] = (kInnerCircleRadius + kOuterCircleRadius) / 2.0;
	playback.listenerPos[2] = 0;
	// and points to the source (cube)
	playback.listenerRotation = 0;
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationFrameInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
			[displayLink setFrameInterval:animationFrameInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}

- (void)dealloc {
    
	[playback stopSound];
	
	// release textures
	glDeleteTextures(5, texture);
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
	
    [super dealloc];
}

#pragma mark TouchEvents

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	UITouch* touch = ([touches count] == 1 ? [touches anyObject] : nil);
	
	if (touch)
	{
		// Convert touch point from UIView referential to OpenGL one (upside-down flip)
		CGRect bounds = [self bounds];
		CGPoint location = [touch locationInView:self];
		location.y = bounds.size.height - location.y;
		
		if (!showDesc)
		{
			// Compute the bounds of the four buttons (1,2,3,4)
			// for 2D drawing,  projection transform is set to glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, -10.0f, 10.0f);
			GLint buttonSize = kButtonScale*backingWidth;
			GLint xmin, xmax, ymin, ymax;
			xmin = 0;
			xmax = buttonSize;
			ymax = (1 - kButtonLeftSpace/3.0) * backingHeight;
			ymin = ymax - buttonSize*4;
		
			// if touch point is in the bounds, compute the selected mode
			if (location.x >= xmin && location.x < xmax && location.y >= ymin && location.y < ymax)
			{
				GLint m = (location.y - ymin) / buttonSize;
				// clamp to 0~3
				m = m<0 ? 0 : (m>3 ? 3 : m);
				// our mode is 1~4
				// invert, as the bigger y is, the smaller mode is
				m = 4-m;
		
				// switch to the new mode and update parameters
				if (mode != m)
				{
					mode = m;
			
					// update the position of the cube (sound source)
					// in mode 1 and 2, the teapot (sound source) is at the center of the sound stage
					// in mode 3 and 4, the teapot (sound source) is on the left side
					if (mode <= 2) {
						cubePos[0] = cubePos[1] = cubePos[2] = 0;
					}
					else {
						cubePos[0] = 0; 
						cubePos[1] = (kInnerCircleRadius + kOuterCircleRadius) / 2.0;
						cubePos[2] = 0;
					}
		
					// update playback
					playback.sourcePos = cubePos; //sound source's position
				}
			}
		
			// user touches the info icon at the corner when playing
			else if (location.x >= 0 && location.x < 40 && location.y >= 440 && location.y < 480)
			{
				// show the description and pause
				showDesc = YES;
				[playback stopSound];
			}
		}
		
		// user touches anywhere on the screen when pausing
		else
		{
			// dismiss the description and continue
			showDesc = NO;
			[playback startSound];
		}
	}
}

@end
