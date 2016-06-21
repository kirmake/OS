#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>

/* 
Для запуска

[скоммпилированная программа] [первый файл] [второй файл] ... [n-й файл] [файл для записи результата]

В приложенном примере t6test1 и t6test2 использовались, как файлы для извлечения чисел, а результат записан в t6test3

*/




#define MAX_AMMOUNT 10000

long long numbers[MAX_AMMOUNT];
long long numbersAmmount = 0;

int compare (const void * a, const void * b) { 
	long long x = *((long long*)a); 
	long long y = *((long long*)b); 
	if (x == y) return 0; 
	return (x > y)? 1 : -1;  
}

int read_file(char *name) {
	int n;
	int num_flag = 0;
	int fildes = open(name, O_RDONLY, S_IRWXU);
	if (fildes == -1) {
		printf("Unable to open file %s\n", name);
		return 1;
	}
	char c;
	long long number = 0;
	while((n = read(fildes, &c, 1)) != 0){
		if ('0' <= c && c <= '9') {
			num_flag = 1;
			number = number * 10;
			number = number + (c - '0');
		} else {
			if (num_flag != 0) {
				numbers[numbersAmmount] = number;
				//printf("%d\n",number);
				numbersAmmount++;
				if (numbersAmmount == MAX_AMMOUNT) {
					printf("Too much numbers\n");
						close(fildes);
						return 1;
					}
				number = 0;
				num_flag = 0;
			}
		}	
	}
	close(fildes);
	return 0;
}

int main(int argc, char *argv[]){
	if (argc < 2) {
			printf("Wrong number of arguments\n");
			return 0;
	}
	int n;
	long long i;
	
	for (i = 1; i < argc - 1; i++) {
		if ((n = read_file(argv[i])) == 1) {
			return 0;
		}
	}
	qsort(numbers, (size_t)numbersAmmount, sizeof(long long), compare);
	
	
	FILE *f = fopen(argv[argc - 1], "w");
	if (f == NULL) {
		printf ("Unable to open file %s\n", argv[argc - 1]);
		return 0;
	}

	for (i = 0; i < numbersAmmount; i++) {
		int n = fprintf(f, "%llu\n", numbers[i]);
		if (n <= 0) {
			printf ("Unable to write into file %s\n", argv[argc - 1]);
			fclose(f);
			return 0;
		}
	}
	fclose(f);
	return 0;
}