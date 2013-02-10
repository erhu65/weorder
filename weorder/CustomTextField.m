//
//  CustomTextField.m
//  Surf's Up
//
//  Created by Steven Baranski on 9/16/11.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
	return CGRectInset(bounds, 5, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	return CGRectInset(bounds, 5, 0);	
}

- (void)drawRect:(CGRect)rect
{
    UIImage *textFieldBackground = [[UIImage imageNamed:@"text_field_teal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 5.0, 15.0, 5.0)];
    [textFieldBackground drawInRect:[self bounds]];
}

@end
