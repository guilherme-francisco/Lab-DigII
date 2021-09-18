


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rx_serial_8N2 is 
    port  
    ( 
        clock:         in  std_logic;  
        reset:         in  std_logic; 
        dado_serial:   in  std_logic; 
        recebe_dado:   in  std_logic; 
        pronto_rx:     out std_logic; 
        tem_dado:      out std_logic; 
        dado_recebido: out std_logic_vector (7 downto 0); 
        db_estado:     out std_logic_vector (6 downto 0)  -- estado da UC 
    ); 
end entity; 

architecture rx_serial_8N2_arch of rx_serial_8N2_8N2 is
     
    component rx_serial_tick_uc port ( 
            clock, reset, partida, tick, fim:      in  std_logic;
            zera, conta, carrega, desloca, pronto: out std_logic 
    );
    end component;

    component rx_serial_8N2_fd port (
        clock, reset: in std_logic;
        zera, conta, carrega, desloca: in std_logic;
        dados_ascii: in std_logic_vector (7 downto 0);
        saida_serial, fim : out std_logic
    );
    end component;
    
    component contador_m
    generic (
        constant M: integer; 
        constant N: integer 
    );
    port (
        clock, zera, conta: in std_logic;
        Q: out std_logic_vector (N-1 downto 0);
        fim: out std_logic
    );
    end component;
    
    component edge_detector is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;
    
    signal s_reset, s_partida, s_partida_ed: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;
    s_partida <= partida;

    -- unidade de controle
    U1_UC: rx_serial_tick_uc port map (clock, s_reset, s_partida_ed, s_tick, s_fim,
                                       s_zera, s_conta, s_carrega, s_desloca, pronto);

    -- fluxo de dados
    U2_FD: rx_serial_8N2_fd port map (clock, s_reset, s_zera, s_conta, s_carrega, s_desloca, 
                                      dados_ascii, saida_serial, s_fim);

    -- gerador de tick
    -- fator de divisao 50MHz para 9600 bauds (5208=50M/9600), 13 bits
    U3_TICK: contador_m generic map (M => 5208) port map (clock, s_zera, '0',  '1', open, open, s_tick);
 
    -- detetor de borda
    U4_ED: edge_detector port map (clock, s_partida, s_partida_ed);
     
end architecture;