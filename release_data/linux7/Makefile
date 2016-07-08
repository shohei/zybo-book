CFLAGS=-g -Wall -O3

APPLICATIONS=memwrite memread streamread streamwrite fifo

all: 	$(APPLICATIONS)

fifo:	fifo.c
	gcc  $(CFLAGS) -pthread $@.c -o $@

led_matrix_write:	led_matrix_write.c
	gcc  $(CFLAGS) -pthread $@.c -o $@

led_matrix_off:	led_matrix_off.c
	gcc  $(CFLAGS) -pthread $@.c -o $@

led_matrix_bmp:	led_matrix_bmp.c
	gcc  $(CFLAGS) -pthread $@.c -o $@

led_matrix_bmp_rd:	led_matrix_bmp_rd.c
	gcc  $(CFLAGS) -pthread $@.c -o $@

%: 	%.c
	gcc  $(CFLAGS) $@.c -o $@

clean:
	rm -f *~ $(APPLICATIONS)
