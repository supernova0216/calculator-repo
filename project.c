#include <stdio.h>
#include <stdint.h> 
#include <stdlib.h>

int8_t get_input(int8_t* input){
	scanf("%hhd", input);
	printf("\n");
	return *input;
	}
	
void get_expression(char* expression){
	printf("Enter an expression (e.g. ( 6 + ( 5 * 4 ) ) / 2)");
}

void print_machine_status(int8_t value){
	printf("%d", value);
	printf("\n");
	
}
int32_t get_modulo(int32_t* input){
	scanf("%d", input);
	printf("\n");
	return *input;
}
void print_modulo(int32_t value){
	printf("Modulo value is: ");
	printf("%d", value);
	printf("\n");
}
int32_t get_decimal(int32_t* input){
	scanf("%d", input);
	printf("\n");
	return *input;
}
void print_binary(int32_t value){
	printf("Binary value is: ");
	printf("%d", value);
	printf("\n");
}
int32_t get_binary(int32_t *input){
	scanf("%d", input);
	printf("\n");
	return *input;
}
void print_decimal(int32_t value){
	printf("Decimal value is: ");
	printf("%d", value);
	printf("\n");
}
void printstuff(int8_t debug){
	printf("%d", debug);
	printf("/n");
}

double get_num(double* num)
{
	scanf("%lf", num);
	return *num;
}

void print(double a)
{
	printf("Result is: %.3lf", a);
	return;
}
