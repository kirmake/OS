#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>


/* 
Для запуска

gzip -cd [архив] | [скоммпилированная программа] [имя файла для записи результата]


*/

const unsigned int buff_len = 2048;

int unzip(char * name) {
	int n;
	int i;
	char buff[buff_len];
	int fildes = open(name, O_WRONLY | O_TRUNC | O_CREAT , S_IRWXU);
	if (fildes == -1) {
		printf("Unable to open file");
		return 1;
	}
	while((n = read(0, buff, buff_len))!=0){
		for (i = 0; i < n; i++) {
			if (buff[i] == 0) {
				lseek (fildes, 1, SEEK_CUR);
			} else {
				write(fildes, &buff[i], 1);
			}
		}
	}
	close(fildes);
	return 0;
}

int main(int argc, char *argv[]){
	if (argc == 2) {
			return unzip(argv[1]);
	}
	printf("Wrong number of arguments");
}
