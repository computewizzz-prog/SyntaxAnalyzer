// Test Case 1: Valid program with variables and arithmetic
// This should parse successfully

int main() {
    int x, y, z;
    float result;
    
    x = 10;
    y = 20;
    z = x + y * 2;
    result = (float)(z) / 3.0;
    
    return 0;
}