#include <stdio.h>
#include <stdlib.h>

extern int decode128(unsigned char *source_bitmap, int scan_line_no, char *text);

unsigned char* loadBMP(const char* filename)
{
    FILE* file = fopen(filename, "rb");
    if (!file)
    {
        printf("Failed to open file: %s\n", filename);
        return NULL;
    }

    unsigned char header[54];
    fread(header, sizeof(unsigned char), 54, file);

    int dataOffset = *(int*)&header[10];
    int imageWidth = *(int*)&header[18];
    int imageHeight = *(int*)&header[22];
    int imageSize = *(int*)&header[34];

    if (imageWidth != 600 || imageHeight != 50)
    {
        printf("Image dimensions are not 600x50\n");
        fclose(file);
        return NULL;
    }
    unsigned char* imageData = (unsigned char*)malloc(imageSize);
    if (!imageData) {
        printf("Failed to allocate memory for image data\n");
        fclose(file);
        return NULL;
    }
    fseek(file, dataOffset+4, SEEK_SET);
    fread(imageData, sizeof(unsigned char), imageSize, file);

    fclose(file);
    return imageData;
}

int main(void)
{
    const char* filename = "3.bmp";
    unsigned int width, height;
    int y_coordinate_line = 25;
    char text[256];
    int result;
    unsigned char* image = loadBMP(filename);
    if (image)
    {
        printf("File opened succesfully\n");
        result=decode128(image, y_coordinate_line, text);
        printf("Result %i\n", result);
        if(result == 0)
            printf("Decoded text: %s\n", text);
        else if (result == 1)
            printf("Wrong start symbol\n");
        else if (result == 2)
            printf("Wrong checksum\n");
        else if (result == -1)
            printf("Wrong stop symbol\n");
        else
            printf("Error occured\n");
        free(image);
    }
    else
    {
        printf("Failed to load BMP: %s\n", filename);
    }

return 0;
}
