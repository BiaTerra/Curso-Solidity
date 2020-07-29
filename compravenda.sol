/*
Projeto:

Objetivo:
- Regrar a compra e venda de um prédio, com diversas unidades autônomas locadas a diferentes pessoas;
- Criar um mecanismo para possibilitar o exercício do direito de preferência pelos locatários;
- Criar um mecanismo para possibilitar a denúncia das locações após a venda, caso todas as locações sejam passíveis de denúncia, ou para migrar o pagamento do aluguel ao novo proprietário;

Partes:
- Vendedor
    - conta / payable
    
- Locatário(s)
    - conta
    - unidade autônoma alugada
    - valor do aluguel
    - passível de denúncia, cf. art. 8º da Lei Federal nº 8.245/1991
        - contrato de locação vidente por prazo indeterminado
        - contrato de locação que não contenha cláusula de vigência
        - cláusula de vigência não averbada no Registro de Imóveis
    
- Comprador
    - conta / payable
    
- Objeto
    - imóvel
        - nº da matrícula
        - contribuinte

- Eventos
    - exercício da preferência
    - aquisição concluída
    - denúncia das locações 

- Funções
    - registrar imóveis
    - registrar locatários
    - exercer a preferência
    - realizar aquisição
    - verificar locações passíveis de denúncia
    - denunciar locações
    - pagar aluguel
 
/*

// SPDX-License-Identifier: GLP-3.0
pragma solidity 0.6.10;

contract CompraEVenda {

    // structs
    struct Locatario {
        string nomeLocatario;
        string imovelAlugado;
        address endereco;
        uint256 valorAluguel;
        bool contratoVigentePorPrazoDeterminado;
        bool haClausulaDeVigencia;
        bool contratoAverbadoNoRI;
    }
    
    struct Predio {
        uint256 numeroMatricula;
        string numeroContribuinte;
        string unidadeAutonoma;
    }
    
    // informações do vendedor
    address payable public contaVendedor;
    
    // informações do comprador
    address payable public comprador;
    modifier somenteComprador(){
        require(comprador == msg.sender, "Somente o comprador pode realizar esta operação.");
        _;
    }
    
    // condições da aquisição
    uint256 public preco;
    uint256 public constant parcelas = 10;
    uint256 public parcelasPagas;
    uint256 public valorParcela;
    
    // informações dos locatários
    Locatario[] public locatarios;
    
    // aspectos do direito de preferência
    uint256 public prazoPreferencia = now + 2592000; // Prazo do art. 28 da Lei Federal nº 8.245/1991
    bool public preferenciaExercida = false;
    
    // status da aquisicaoConcluida
    bool public precoAquisicaoQuitado = false;
    bool public aquisicaoJaRealizada = false;
    
    // aspectos da denúncia das locações
    uint256 public prazoDenunciaLocacao = now + 10368000; // Prazo do §2º do art. 8º da Lei Federal nº 8.245/1991
    bool public todasAsLocacoesSaoPassiveisDeDenuncia = true;
    bool public locacoesDenunciadas = false;
   
    // eventos
    event exercidaAPreferencia (address locatarioComprador);
    event aquisicaoConcluida ();
    event locacoesDenunciadasPeloComprador ();
    event aluguelPago (address Locatario, uint256 );
    
    constructor (
        uint256 precoDeAquisicao,
        address payable contaDoVendedor
        )
        public {
            preco = precoDeAquisicao;
            contaDoVendedor = contaVendedor;
            valorParcela = preco/parcelas;
        }
        
    function ajustaPreco (uint256 debitoIPTU) public somenteComprador {
        if (debitoIPTU > 0) {
        preco = preco - debitoIPTU;
        valorParcela = preco/parcelas;
        }
    }
   
   function registraLocatario (string memory _nomeLocatario, string memory _imovelAlugado, address _endereco, uint256 _valorAluguel, bool _contratoVigentePorPrazoDeterminado, bool _haClausuladeVigencia, bool _contratoRegistradoNoRI) public {
       Locatario memory locTemp = Locatario (_nomeLocatario, _imovelAlugado, _endereco, _valorAluguel, _contratoVigentePorPrazoDeterminado, _haClausuladeVigencia, _contratoRegistradoNoRI);
       locatarios.push(locTemp);
   }
   
   function exercerPreferencia (uint256 _indiceImovel) public payable {
       require (now <= prazoPreferencia, "Decorrido o prazo legal para exercício do direito de preferência."); // cf. art. 28 da Lei Federal nº 8.245/1991
       require (msg.value == preco, "O direito de preferência deve ser exercício em igual condição a terceiros."); // cf. art. 27 da Lei Federal nº 8.245/1991
       require (locatarios[_indiceImovel].endereco == msg.sender, "Operação somente autorizada para locatários.");
       require (!preferenciaExercida, "Direito de preferência já exercido por outro locatário.");
       preferenciaExercida = true;
       emit exercidaAPreferencia (msg.sender);
    }
   
   function pagarParcela () public payable somenteComprador {
       require (now > prazoPreferencia, "Aguardar transcurso do prazo legal para exercício de preferência dos locatários.");
       require (!preferenciaExercida, "Direito de preferência exercido por locatário.");
       require (msg.value == valorParcela, "Valor diferente do acordado.");
       require (!precoAquisicaoQuitado);
       parcelasPagas = parcelasPagas + 1;
       if (parcelasPagas == parcelas) {
           precoAquisicaoQuitado = true;
           aquisicaoJaRealizada = true;
           emit aquisicaoConcluida ();
       }
    }
    
    function verificarLocacaoNaoPassivelDeDenuncia () view public returns (bool) {
        for (uint256 indice; indice < locatarios.length; indice ++) {
            Locatario memory locTemp = locatarios[indice];
            if (locTemp.contratoVigentePorPrazoDeterminado && locTemp.haClausulaDeVigencia && locTemp.contratoAverbadoNoRI) {
                return true;
            }
        }
        
    }
    
    function denunciarLocacao () public {
        require (now <= prazoDenunciaLocacao, "Decorrido o prazo para denúncia da locação.");
        require (aquisicaoJaRealizada == true);
        require (todasAsLocacoesSaoPassiveisDeDenuncia == true);
        emit locacoesDenunciadasPeloComprador ();
    }
}
