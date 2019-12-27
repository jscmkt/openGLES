

#import <Foundation/Foundation.h>
NSString * intToBinary(int intValue);
int main(int argc, const char * argv[]){
    NSLog(@"%@",intToBinary( 1|3));
    return 0;
}
NSString * intToBinary(int intValue){
    int byteBlock = 8,            // 8 bits per byte
    totalBits = (sizeof(int)) * byteBlock, // Total bits
    binaryDigit = totalBits; // Which digit are we processing   // C array - storage plus one for null
    char ndigit[totalBits + 1];
    while (binaryDigit-- > 0)
    {
        // Set digit in array based on rightmost bit
        ndigit[binaryDigit] = (intValue & 1) ? '1' : '0';
        // Shift incoming value one to right
        intValue >>= 1;  }   // Append null
    ndigit[totalBits] = 0;
    // Return the binary string
    return [NSString stringWithUTF8String:ndigit];

}
