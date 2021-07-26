library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Trooper is
    port (
        SWC, SWB, SWA, clr, C, Z, W1, W2, W3, T3, QD : in std_logic;
        IRH : in std_logic_vector(3 downto 0);
        SELCTL, ABUS, M, SEL3, SEL2, SEL1, SEL0, DRW, SBUS, LIR, MBUS, MEMW, LAR, ARINC, LPC, PCINC, PCADD, CIN, LONG, SHORT, STOP, LDC, LDZ : out std_logic;
        S : out std_logic_vector(3 downto 0)
    );
end Trooper;

architecture arc of Trooper is
    signal SWCBA : std_logic_vector(2 downto 0);
    signal ST0, SST0 : std_logic;
    signal st_PC_IR : std_logic;
begin
    SWCBA <= SWC & SWB & SWA;
    
	process (st_PC_IR)
	begin 
		LIR <= '0';
		PCINC <= '0';
		if (st_PC_IR = '1') then
			case SWCBA is
					when "000" =>
						if (ST0 = '1') then
							case IRH is
								when "0000" => --NOP
									LIR <= W1;
									PCINC <= W1;

								when "0001" => --ADD
									LIR <= W1;
									PCINC <= W1;

								when "0010" => --SUB
									LIR <= W1;
									PCINC <= W1;

								when "0011" => --AND
									LIR <= W1;
									PCINC <= W1;

								when "0100" => --INC
									LIR <= W1;
									PCINC <= W1;

								when "0101" => --LD
									LIR <= W2;
									PCINC <= W2;
									
								when "0110" => --ST
									LIR <= W2;
									PCINC <= W2;

								when "0111" => --JC
									LIR <= (W1 and (not C)) or (W2 and C);
									PCINC <= (W1 and (not C)) or (W2 and C);

								when "1000" => --JZ
									LIR <= (W1 and (not Z)) or (W2 and Z);
									PCINC <= (W1 and (not Z)) or (W2 and Z);

								when "1001" => --JMP
									LIR <= W2;
									PCINC <= W2;

								when "1010" => --OUT
									LIR <= W1;
									PCINC <= W1;

								when "1011" => --XOR
									LIR <= W1;
									PCINC <= W1;

								when "1100" => --OR
									LIR <= W1;
									PCINC <= W1;

								when "1101" => --NOT
									LIR <= W1;
									PCINC <= W1;
								
								when others => null;
							end case;
						end if;
					when others => null;
				end case;

		end if;
	end process;

	process (T3, CLR)
	begin
		st_PC_IR <= '0';
		
		if (CLR = '0') then
			ST0 <= '0';
		else
			if (T3'event and T3 = '0') and SST0 = '1' then
				ST0 <= '1';
			end if;
			
			st_PC_IR <= '1';
		end if;
	end process;

    process (SWCBA, IRH, W1, W2, W3, ST0, C, Z)
    begin
        SHORT <= '0';
        LONG <= '0';
        CIN <= '0';
        SELCTL <= '0';
        ABUS <= '0';
        SBUS <= '0';
        MBUS <= '0';
        M <= '0';
        S <= "0000";
        SEL3 <= '0';
        SEL2 <= '0';
        SEL1 <= '0';
        SEL0 <= '0';
        DRW <= '0';
        SBUS <= '0';
        MEMW <= '0';
        LAR <= '0';
        ARINC <= '0';
        LPC <= '0';
        LDZ <= '0';
        LDC <= '0';
        STOP <= '0';
        SST0 <= '0';
        PCADD <= '0';

        
         case SWCBA is
                when "000" =>
                    if ST0 = '0' then
                        LPC <= W1;
                        SBUS <= W1;
                        SST0 <= W1;
                        SHORT <= W1;
                        STOP <= W1;
                    else
                        case IRH is
                            when "0000" => --NOP
                                SHORT <= W1;

                            when "0001" => --ADD
                                SHORT <= W1;
                                S <= "1001";
                                CIN <= W1;
                                ABUS <= W1;
                                DRW <= W1;
                                LDC <= W1;
                                LDZ <= W1;

                            when "0010" => --SUB
                                SHORT <= W1;
                                S <= "0110";
                                ABUS <= W1;
                                DRW <= W1;
                                LDC <= W1;
                                LDZ <= W1;

                            when "0011" => --AND
                                SHORT <= W1;
                                S <= "1011";
                                M <= W1;
                                ABUS <= W1;
                                DRW <= W1;
                                LDZ <= W1;

                            when "0100" => --INC
                                SHORT <= W1;
                                S <= "0000";
                                ABUS <= W1;
                                DRW <= W1;
                                LDC <= W1;
                                LDZ <= W1;

                            when "0101" => --LD
                                S <= "1010";
                                M <= W1;
                                ABUS <= W1;
                                LAR <= W1;
                                MBUS <= W2;
                                DRW <= W2;

                            when "0110" => --ST
                                M <= W1 or W2;
                                S(3) <= '1';
                                S(2) <= W1;
                                S(1) <= '1';
                                S(0) <= W1;
                                ABUS <= W1 or W2;
                                LAR <= W1;
                                MEMW <= W2;

                            when "0111" => --JC
                                PCADD <= C and W1;
                                SHORT <= W1 and (not C);

                            when "1000" => --JZ
                                PCADD <= Z and W1;
                                SHORT <= W1 and (not Z);

                            when "1001" => --JMP
                                M <= W1;
                                S <= "1111";
                                ABUS <= W1;
                                LPC <= W1;

                            when "1010" => --OUT
    							M <= W1;
    							S <= "1010";
    							ABUS <= W1;
    							SHORT <= W1;

    						when "1011" => --XOR
    							SHORT <= W1;
    							M <= W1;
    							S <= "0110";
    							ABUS <= W1;
    							LDZ <= W1;
    							DRW <= W1;

    						when "1100" => --OR
    							SHORT <= W1;
    							M <= W1;
    							S <= "1110";
    							ABUS <= W1;
    							LDZ <= W1;
    							DRW <= W1;

    						when "1101" => --NOT
    							SHORT <= W1;
    							M <= W1;
    							S <= "0101";
    							ABUS <= W1;
    							LDZ <= W1;
    							DRW <= W1;


                            when "1110" => --STP
                                STOP <= W1;

                            when others => null;
                        end case;
                    end if;

                when "001" =>
                    SELCTL <= W1;
                    SHORT <= W1;
                    SBUS <= W1;
                    STOP <= W1;
                    SST0 <= W1;
                    LAR <= W1 and (not ST0);
                    ARINC <= W1 and ST0;
                    MEMW <= W1 and ST0;

                when "010" =>
                    SELCTL <= W1;
                    SHORT <= W1;
                    SBUS <= W1 and (not ST0);
                    MBUS <= W1 and ST0;
                    STOP <= W1;
                    SST0 <= W1;
                    LAR <= W1 and (not ST0);
                    ARINC <= W1 and ST0;

                when "011" =>
                    SELCTL <= '1';
                    SEL0 <= W1 or W2;
                    STOP <= W1 or W2;
                    SEL3 <= W2;
                    SEL1 <= W2;

                when "100" =>
                    SELCTL <= '1';
                    SST0 <= W2;
                    SBUS <= W1 or W2;
                    STOP <= W1 or W2;
                    DRW <= W1 or W2;
                    SEL3 <= (ST0 and W1) or (ST0 and W2);
                    SEL2 <= W2;
                    SEL1 <= ((not ST0) and W1) or (ST0 and W2);
                    SEL0 <= W1;

                when others => null;
            end case;
    end process;
end arc;
