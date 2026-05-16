/* Define the minimum sizes for Heap and Stack */
_Min_Heap_Size = 0x200;  /* 512 Bytes */
_Min_Stack_Size = 0x400; /* 1024 Bytes */

MEMORY
{
    /* define the memory in the device */
    /* should be explicitly called MEMORY */
    /* each memory names inside could be anything */
    /* syntax: Mem_NAME (rwx) : ORIGIN = <address>, LENGTH = <len> */

    FLASH (rx)    : ORIGIN = 0x08000000, LENGTH = 512k

    SRAM1 (rwx)   : ORIGIN = 0x20000000, LENGTH = 80k
    SRAM2 (rwx)   : ORIGIN = 0x20014000, LENGTH = 16k
    CCM_RAM (rwx) : ORIGIN = 0x10000000, LENGTH = 16k      
}

SECTIONS 
{
    .isr_vector :
    {
        . = ALIGN(4);           /* Align to 4-byte boundary */
        KEEP(*(.isr_vector))    /* Grab the .isr_vector section from */
                                /* every file and DO NOT DELETE IT */
                                /* even if it is referenced nowhere */
        . = ALIGN(4);           /* Align 4 bytes = 32 bits */
    } > FLASH

    .text :
    {
        . = ALIGN(4);   /* . is the location counter */
        *(.text)        /* grab all standard executable code */
        *(.text.*)
        *(.rodata)      /* grab all read only data */
        *(.rodata.*)

        . = ALIGN(4);   /* align again at the end */
        _etext = .;     /* assign the current memory address to variable _etext */

    } > FLASH           /* burn all of this permanently into FLASH */

    .data :
    {
        . = ALIGN(4);
        _sdata = .;      /* assign the current memory address to variable _sdata */
        *(.data)         /* grab all initialized variables */
        *(.data.*)
        . = ALIGN(4);
        _edata = .;
    } > SRAM1 AT > FLASH 

    .bss :
    {
        . = ALIGN(4);
        _sbss = .;      /* assign the current memory address to variable _sbss */
        *(.bss)
        *(.bss.*)
        . = ALIGN(4);
        _ebss = .;
    } > SRAM1           

    ._user_heap_stack :
    {
        . = ALIGN(8);
        
        /* Mark where the Heap starts for the standard C library */
        PROVIDE ( end = . ); 
        PROVIDE ( _end = . );
        
        /* Fast-forward the tape measure to see if we hit the wall */
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        
        . = ALIGN(8);
    } > SRAM1            
}