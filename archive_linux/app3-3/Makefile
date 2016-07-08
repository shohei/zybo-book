CFLAGS=-g -Wall -O3

APPLICATIONS=httpclient putfiltercoeff calcfft readfifo

all: 	$(APPLICATIONS)

fifo:	fifo.c
	gcc  $(CFLAGS) -pthread $@.c -o $@

%: 	%.c
	gcc  $(CFLAGS) $@.c -lm -o $@

clean:
	rm -f *~ $(APPLICATIONS)
