Petrol Pump Management System (x86 Assembly)

A 16-bit x86 Assembly language console application built for emulator platforms such as EMU8086. This application simulates a complete petrol pump point-of-sale (POS) terminal, managing fuel sales, automatic billing discounts, worker performance evaluation, and daily sales summary tracking.

Fuel Pricing

|Fuel Type | Choice Key |Unit Price(tk/Litre) |
|----------|------------|---------------------|
|  Petrol  |     1      |       100           |
|  Diesel  |     2      |       80            |
|  Octane  |     3      |       120           |

#Features

**Fuel Selection & Array Pricing: Dynamically fetches pricing using word-array offset calculations based on user input.

**Automated Discounts: Automatically applies a 10% discount on orders strictly exceeding 10 Litres.

**Payment & Change Calculation: Ensures sufficient payment before generating transaction receipts and calculating change.

**Worker Hours & Performance Evaluation: Calculates worker pay (50 tk/hr) and evaluates performance status based on shift duration (8+ hours threshold for "Good Worker").

**Daily Sales Summary: Keeps continuous track of total customers served and aggregate income generated.

**Built-in I/O Utilities: Custom 16-bit procedures for screen clearing (INT 10h), multi-digit number reading, and ASCII print formatting (INT 21h).

#Prerequisites & Setup

Install EMU8086.

Clone or download your project folder containing project.asm.

#Running in EMU8086

Open EMU8086.

Open project.asm.

Click the Emulate button (or press F5).

In the emulator screen, click Run to launch the program.
