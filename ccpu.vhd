library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;

entity ccpu is
    port (
        SWC, SWB, SWA : in std_logic; --这个是用来控制是执行程序 写寄存器 读寄存器 写存储器 读存储器
		CLR: in std_logic; --拥有最高级别 清空
		C, Z : in std_logic;	--carry flag 和 zero flag	
		W1, W2, W3, T3, QD : in std_logic; -- w1 w2 w3是节拍 一般是两个 只有 w1 w2 T3是用它的下降沿来定位的
        IRHIGH : in std_logic_vector(3 downto 0); --高四位的IR
		-- 以上是输入的信号
        SELCTL : out std_logic; --控制台信号
		ABUS, M, CIN :out std_logic; --ABUS是控制 ALU数据是否流出 到DBUS上 M是控制ALU是逻辑运算还是算数运算 CIN是控制操作数可以送入ALU进行计算了
		S : out std_logic_vector(3 downto 0); --控制ALU产生不同的函数
		SEL3, SEL2, SEL1, SEL0 : out std_logic; --用于 2 - 4 的选择
		DRW, SBUS : out std_logic; --自己开关制数
		LIR : out std_logic; --把指令送到指令寄存器
		MBUS, MEMW :  out std_logic; --把双端口存储器的数据送到数据总线 和 读写控制
		LAR, ARINC : out std_logic; --把地址送入双端口存储器 地址自增
		LPC, PCINC, PCADD : out std_logic; --同上 只是对象变成了 PC
		STOP: out std_logic ; --停机指令 
		LDC, LDZ : out std_logic; --送 carryflag 和 zeroflag
		LONG, SHORT :out std_logic --用于产生 W3 和只有 W1
		
    );
end ccpu;

architecture arc of ccpu is
    signal ST0, NEXTST0 : std_logic;
    signal SWCBA : std_logic_vector(2 downto 0);
begin
    SWCBA <= SWC & SWB & SWA;
    process (SWCBA, IRHIGH, W1, W2, W3, T3,CLR,C,Z,ST0,NEXTST0) 
    begin
		SELCTL <= '0';
        SHORT <= '0';
        LONG <= '0';
        CIN <= '0';
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
        LIR <= '0';
        MEMW <= '0';
        LAR <= '0';
        ARINC <= '0';
        LPC <= '0';
        LDZ <= '0';
        LDC <= '0';
        STOP <= '0';
        PCINC <= '0';
        NEXTST0 <= '0';
        PCADD <= '0';

        if (clr = '0') then
            ST0 <= '0';
        else
        
            if (T3'event and T3 = '0') and NEXTST0 = '1' then
                ST0 <= '1';
            end if;

            case SWCBA is
                when "000" =>
                    if ST0 = '0' then
                        LPC <= W1; --这里是PC的指令拓展 为了可以置入PC的值
                        SBUS <= W1;
                        NEXTST0 <= W1;
                        SHORT <= W1;
                        STOP <= W1;
						SELCTL <= W1;
                    else
						LIR <= W1;
						PCINC <= W1;
                        case IRHIGH is
							--加法指令 ADD
                            when "0001" => 
                                S <= w2 & '0' & '0' & w2;
                                CIN <= W2;
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
                                LDC <= W2;
							--减法指令 SUB
                            when "0010" => 
                                S <= '0' & w2 & w2 & '0';
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
                                LDC <= W2;
							-- AND指令
                            when "0011" => 
                                M <= W2;
                                S <= w2 & '0' & w2 & w2;
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
							--自增加一指令 INC
                            when "0100" => --INC
                                S <= '0' & '0' & '0' & '0';
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
                                LDC <= W2;
							--存数指令 LD
                            when "0101" => --LD
                                M <= W2;
                                S <= w2 & '0' & w2 & '0' ;
                                ABUS <= W2;
                                LAR <= W2;
                                LONG <= W2;
                                
                                DRW <= W3;
								MBUS <= W3;
							--取数指令 ST
                            when "0110" => --ST
                                --M <= W1 or W2; 这里写错了导致程序错误
								M <= W2 or W3;
                                S <= (W2 or W3) & W2 & (W2 or W3) & W2;
                                ABUS <= W2 or W3;
                                LAR <= W2;
                                LONG <=W2;
                          
                                MEMW <=W3;
							--有条件跳转 JC
                            when "0111" => --JC
								PCADD <= W2 and C;
							--有条件跳转 JZ
                            when "1000" => --JZ
                                PCADD <= W2 and Z;
							--无条件跳转 JMP
                            when "1001" => --JMP
								M <=W2;
								S <= W2 & W2 & W2 & W2;
								ABUS <= W2;
								LPC <=W2;
							--停机指令 STP
                            when "1110" => --STP
                                STOP <= W2;
                            --接下来是扩展的 通过 ALU的不同功能来拓展
							--展示数的指令 out
                            when "1010" => -- out
								M <= W2;
								S <= W2 & '0' & W2 & '0';
								ABUS <= W2;
							--或 or
                            when "1011" => --或
								M <= W2;
								S <= W2 & W2 & W2 & '0';
								ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
							--与非
							when "1100" => 
								M <= '1';
								S <= '0' & W2 & '0' & '0'; 
								ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
							--或非
                            when "1101" =>
								M <= '1';
								S <= '0' & '0' & '0' & W2; 
								ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
                            when others => null;
                        end case;
                    end if;

                when "001" =>
					SBUS <= W1;
					STOP <= W1;
					SHORT <= W1;
                    SELCTL <= W1;
                    NEXTST0 <= W1;
                    
                    LAR <= W1 and (not ST0);
                    ARINC <= W1 and ST0;
                    MEMW <= W1 and ST0;
                when "010" =>
					STOP <= W1;
					SHORT <= W1;
                    SELCTL <= W1;
                    NEXTST0 <= W1;
                    
                    SBUS <= W1 and (not ST0);
                    LAR <= W1 and (not ST0);
                    MBUS <= W1 and ST0;
                    ARINC <= W1 and ST0;
                when "011" =>
                    SELCTL <= W1 or W2;
                    STOP <= W1 or W2;
                    
                    SEL0 <= W1 or W2;
                    SEL1 <= W2;
                    SEL2 <= '0';
                    SEL3 <= W2;
                when "100" =>
                    SELCTL <= W1 or W2;
                    SBUS <= W1 or W2;
                    STOP <= W1 or W2;
                    NEXTST0 <= W2;
                    DRW <= W1 or W2;
                    
                    SEL3 <= (ST0 and W1) or (ST0 and W2);
                    SEL2 <= W2;
                    SEL1 <= ((not ST0) and W1) or (ST0 and W2);
                    SEL0 <= W1;
                when others => null;
            end case;
        end if;
    end process;
end arc;
