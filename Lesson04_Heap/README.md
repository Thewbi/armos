# Heap

A heap is a datastructure that is used to manage memory.

Virtual memory also is a feature that allows you to manage memory. So that definition is too simple.

The difference between virtual memory and a heap is granularity. Virtual memory manages pages in blocks of
usually 4KB, 16KB or 64KB. A heap allows an application or the kernel itself to allocate very small or very large
amounts of memory. A application could create an array of three integers which would be 24 bytes in size. This
is a very small amount of memory compared to a 4KB block. Hence the Heap safes memory. The heap can be used with
or without underlying virtual memory.

A heap will grow and shrink. If the application reserves more and more memory it has to request a new block
from the operating system so it can extend into that block. If the heap grows it moves its upper bound. The upper
bound is usually called the break. The operation that the heap calls to request new memory is called brk() to
denate that the break is moved.
