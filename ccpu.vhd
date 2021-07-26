library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;

entity ccpu is
    port (
        SWC, SWB, SWA : in std_logic; --���������������ִ�г��� д�Ĵ��� ���Ĵ��� д�洢�� ���洢��
		CLR: in std_logic; --ӵ����߼��� ���
		C, Z : in std_logic;	--carry flag �� zero flag	
		W1, W2, W3, T3, QD : in std_logic; -- w1 w2 w3�ǽ��� һ�������� ֻ�� w1 w2 T3���������½�������λ��
        IRHIGH : in std_logic_vector(3 downto 0); --����λ��IR
		-- ������������ź�
        SELCTL : out std_logic; --����̨�ź�
		ABUS, M, CIN :out std_logic; --ABUS�ǿ��� ALU�����Ƿ����� ��DBUS�� M�ǿ���ALU���߼����㻹���������� CIN�ǿ��Ʋ�������������ALU���м�����
		S : out std_logic_vector(3 downto 0); --����ALU������ͬ�ĺ���
		SEL3, SEL2, SEL1, SEL0 : out std_logic; --���� 2 - 4 ��ѡ��
		DRW, SBUS : out std_logic; --�Լ���������
		LIR : out std_logic; --��ָ���͵�ָ��Ĵ���
		MBUS, MEMW :  out std_logic; --��˫�˿ڴ洢���������͵��������� �� ��д����
		LAR, ARINC : out std_logic; --�ѵ�ַ����˫�˿ڴ洢�� ��ַ����
		LPC, PCINC, PCADD : out std_logic; --ͬ�� ֻ�Ƕ������� PC
		STOP: out std_logic ; --ͣ��ָ�� 
		LDC, LDZ : out std_logic; --�� carryflag �� zeroflag
		LONG, SHORT :out std_logic --���ڲ��� W3 ��ֻ�� W1
		
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
                        LPC <= W1; --������PC��ָ����չ Ϊ�˿�������PC��ֵ
                        SBUS <= W1;
                        NEXTST0 <= W1;
                        SHORT <= W1;
                        STOP <= W1;
						SELCTL <= W1;
                    else
						LIR <= W1;
						PCINC <= W1;
                        case IRHIGH is
							--�ӷ�ָ�� ADD
                            when "0001" => 
                                S <= w2 & '0' & '0' & w2;
                                CIN <= W2;
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
                                LDC <= W2;
							--����ָ�� SUB
                            when "0010" => 
                                S <= '0' & w2 & w2 & '0';
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
                                LDC <= W2;
							-- ANDָ��
                            when "0011" => 
                                M <= W2;
                                S <= w2 & '0' & w2 & w2;
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
							--������һָ�� INC
                            when "0100" => --INC
                                S <= '0' & '0' & '0' & '0';
                                ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
                                LDC <= W2;
							--����ָ�� LD
                            when "0101" => --LD
                                M <= W2;
                                S <= w2 & '0' & w2 & '0' ;
                                ABUS <= W2;
                                LAR <= W2;
                                LONG <= W2;
                                
                                DRW <= W3;
								MBUS <= W3;
							--ȡ��ָ�� ST
                            when "0110" => --ST
                                --M <= W1 or W2; ����д���˵��³������
								M <= W2 or W3;
                                S <= (W2 or W3) & W2 & (W2 or W3) & W2;
                                ABUS <= W2 or W3;
                                LAR <= W2;
                                LONG <=W2;
                          
                                MEMW <=W3;
							--��������ת JC
                            when "0111" => --JC
								PCADD <= W2 and C;
							--��������ת JZ
                            when "1000" => --JZ
                                PCADD <= W2 and Z;
							--��������ת JMP
                            when "1001" => --JMP
								M <=W2;
								S <= W2 & W2 & W2 & W2;
								ABUS <= W2;
								LPC <=W2;
							--ͣ��ָ�� STP
                            when "1110" => --STP
                                STOP <= W2;
                            --����������չ�� ͨ�� ALU�Ĳ�ͬ��������չ
							--չʾ����ָ�� out
                            when "1010" => -- out
								M <= W2;
								S <= W2 & '0' & W2 & '0';
								ABUS <= W2;
							--�� or
                            when "1011" => --��
								M <= W2;
								S <= W2 & W2 & W2 & '0';
								ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
							--���
							when "1100" => 
								M <= '1';
								S <= '0' & W2 & '0' & '0'; 
								ABUS <= W2;
                                DRW <= W2;
                                LDZ <= W2;
							--���
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
