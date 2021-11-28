------------------------------------------------------------------
-- Arquivo   : tx_dados_porta_fd.vhd
-- Projeto   : Semana 3 - Porta Inteligente
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito
--             > implementa saida ASCII 
------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_dados_porta_fd is 
	port ( 
		clock:            in  std_logic; 
		reset:            in  std_logic; 
		conta:      	   in  std_logic; 
		partida:			   in  std_logic;
		zera:				   in  std_logic;
		caractere5:       in  std_logic_vector(7 downto 0); -- digitos ASCII 
		caractere4:       in  std_logic_vector(7 downto 0);
		caractere3:       in  std_logic_vector(7 downto 0);
		caractere2:       in  std_logic_vector(7 downto 0);
		caractere1:       in  std_logic_vector(7 downto 0);
		caractere0:       in  std_logic_vector(7 downto 0); 
		recebe_dado:	  	in  std_logic; 
		dado_serial:		in	 std_logic;
		fim:					out std_logic;
		pronto_tx:			out std_logic;
		saida_serial:     out std_logic; 
		tem_dado:		   out std_logic;
		dado_recebido:	   out std_logic_vector(7 downto 0);
		db_saida_serial:  out std_logic
	); 
end entity;

architecture dados_porta_fd_arch of tx_dados_porta_fd is

	component mux_8x1_n
		generic (
			constant BITS: integer := 4
		);
		port ( 
			D0 :     in  std_logic_vector (BITS-1 downto 0);
			D1 :     in  std_logic_vector (BITS-1 downto 0);
			D2 :     in  std_logic_vector (BITS-1 downto 0);
			D3 :     in  std_logic_vector (BITS-1 downto 0);
			D4 :     in  std_logic_vector (BITS-1 downto 0);
			D5 :     in  std_logic_vector (BITS-1 downto 0);
			D6 :     in  std_logic_vector (BITS-1 downto 0);
			D7 :     in  std_logic_vector (BITS-1 downto 0);
			SEL:     in  std_logic_vector (2 downto 0);
			MUX_OUT: out std_logic_vector (BITS-1 downto 0)
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
	 
	 
	component uart_8N2
	port ( 
		clock             : in  std_logic; 
		reset             : in  std_logic; 
		transmite_dado    : in  std_logic; 
		dados_ascii       : in  std_logic_vector(7 downto 0); 
		dado_serial       : in  std_logic; 
		recebe_dado       : in  std_logic; 
		saida_serial      : out std_logic; 
		pronto_tx         : out std_logic; 
		db_saida_serial   : out std_logic; 
		dado_recebido_rx  : out std_logic_vector(7 downto 0); 
		tem_dado          : out std_logic; 
		pronto_rx         : out std_logic;  
		db_transmite_dado : out std_logic;  
		db_estado_tx      : out std_logic_vector(3 downto 0); 
		db_recebe_dado    : out std_logic; 
		db_dado_serial    : out std_logic; 
		db_estado_rx      : out std_logic_vector(3 downto 0) 
    );
	end component;
    
	signal s_mux: std_logic_vector(7 downto 0);
	signal ponto 	: std_logic_vector(7 downto 0) := "00101110";
	signal s_contador : std_logic_vector(2 downto 0);
	signal pronto  : std_logic;
	signal s_pronto_tx : std_logic;
begin
	
	-- Componentes
	U1: mux_8x1_n generic map (BITS => 8) port map(caractere5, caractere4, caractere3, caractere2,
																  caractere1, caractere0, ponto, "00000000",
																  s_contador, s_mux);
																  
	U2: contador_m generic map(M => 7, N => 3) port map(clock, zera, conta, s_contador, pronto);
	
	
	U3: uart_8N2 port map (clock, reset, partida, s_mux, dado_serial, recebe_dado, saida_serial, s_pronto_tx, 
								  db_saida_serial, dado_recebido, tem_dado);
	
	pronto_tx <= s_pronto_tx;
	fim <= pronto and s_pronto_tx;
end architecture;