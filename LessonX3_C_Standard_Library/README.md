Is required so that a .elf application can use OS system calls in a unified way.
If the header files of the standard CLib are supported on the OS, C applications can be developed in a platform independant manner. They can be tested on another OS and then be compiled on the custom OS.

https://de.wikipedia.org/wiki/C-Standard-Bibliothek

In jeder standardkonformen betriebssystemgestützten Implementierung (hosted environment) von C muss die C-Standard-Bibliothek in vollem Umfang vorhanden sein. Hingegen müssen freistehende Umgebungen (freestanding environment), wie man sie beispielsweise im Embedded-Bereich häufig antrifft, nur eine festgelegte Untermenge der Standardbibliothek anbieten, um standardkonform zu sein.
