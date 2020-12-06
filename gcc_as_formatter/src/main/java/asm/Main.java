package asm;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import asm.gccas.OutputListener;
import gccas.gcc_asLexer;
import gccas.gcc_asParser;

public class Main {

	public static void main(final String[] args) throws FileNotFoundException {

		// @formatter:off

		//String content = "// this is a comment";
		//String content = "; this is a comment";
		//String content = ";@ this is a comment";
		//String content = ";@\"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\"";
		//String content = ".arm";
		//String content = ".equ t, t";
		//String content = ".equ ARM6_CPU_ID";
		//String content = ".equ ARM6_CPU_ID, 0x410FB767";
		//String content = ".equ ARM6_CPU_ID, 0x410FB767					; this is a comment";
		//String content = ".equ ARM6_CPU_ID, 0x410FB767					;@ CPU id a BCM2835 reports";
		//String content = ".equ ARM6_CPU_ID, 0x410FB767					// this is a comment";
		//String content = ".equ ARM6_CPU_ID, 0x410FB767					//@ CPU id a BCM2835 reports";
		//String content = ".globl LABEL";
		//String content = ".globl LABEL;";
		//String content = ".long 0xE12EF30E";
		//String content = ".balign 4";
		//String content = "label:";
		//String content = "label: ; this is a comment";
		//String content = "mrs r0,cpsr";
		//String content = "mrs r0,cpsr ; this is a comment";
		//String content = "and r1, r0, #0x1F ;@ Mask off the CPU mode bits to register r1";
		//String content = "dr r2, = __SVC_stack_core0";
		//String content = "ldr r1, =#ARM6_CPU_ID";
		//String content = "ands r5, r5, #0x3";
		//String content = ".section \".data.smartstart\", \"aw\"";

		// TODO
		//String content = "#define TEST";
		//String content = "#define I_Bit ( 1 << 7 )";
		//String content = "#define I_Bit (1 << 7 )";
		//String content = "#define I_Bit  (1 << 7)							// Irq flag bit in cpsr (CPUMODE register)";

		//String content = ".equ CPU_FIQMODE_VALUE";
		//String content = ".equ CPU_FIQMODE_VALUE, CPU_FIQMODE_VALUE";
		//String content = ".equ CPU_FIQMODE_VALUE, CPU_FIQMODE_VALUE ;@ CPU in FIQ mode with irq, fiq off";
		//String content = ".equ (CPU_FIQMODE_VALUE)";
		//String content = ".equ (CPU_FIQMODE_VALUE | I_Bit)";
		//String content = ".equ CPU_FIQMODE_VALUE, (CPU_FIQMODE | I_Bit | F_Bit)	;@ CPU in FIQ mode with irq, fiq off";

		//String content = "ldr lr, =SecondarySpin\n";

		//String content = ".section \".text.startup\", \"ax\", %progbits\n";

		// RPi_CPUCurrentMode : .4byte 0;			//  CPU current Mode is 4 byte variable

		// @formatter:on

		final String content = new Scanner(new File("src/test/resources/SmartStart32.S")).useDelimiter("\\Z").next();
//		final String content = new Scanner(new File("src/test/resources/test1.S")).useDelimiter("\\Z").next();

		final gcc_asLexer lexer = new gcc_asLexer(CharStreams.fromString(content));

		final CommonTokenStream tokens = new CommonTokenStream(lexer);
		final gcc_asParser parser = new gcc_asParser(tokens);
		final ParseTree tree = parser.program();

		final ParseTreeWalker walker = new ParseTreeWalker();
		final OutputListener listener = new OutputListener();

		walker.walk(listener, tree);

//		assertThat(listener.getErrors().size(), is(1));
//		assertThat(listener.getErrors().get(0),
//		  is("Method DoSomething is uppercased!"));

	}

}
