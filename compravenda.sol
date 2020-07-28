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
    
    struct Locatario {
        string nomeLocatario;
        string imovelAlugado;
        address endereco;
        uint256 valorAluguel;
        bool contratoVigentePorPrazoDeterminado;
        bool haClausulaDeVigencia;
        bool contratoAverbadoNoRI;
    }
    
    string public comprador;
    address payable public contaComprador;
    string public vendedor;
    address payable public contaVendedor;
    uint256 public preco;
    uint256 public constant parcelas = 10;
    uint256 public valorParcela;
    uint256 public prazoPreferencia = now + 2592000; // Prazo do art. 28 da Lei Federal nº 8.245/1991
    uint256 public prazoDenunciaLocacao = now + 10368000; // Prazo do §2º do art. 8º da Lei Federal nº 8.245/1991
    bool public preferenciaExercida = false;
    Locatario[] public locatarios;
    bool public aquisicaoRealizada = false;
    
    event exercidaAPreferencia (address locatarioComprador);
    event aquisicaoConcluida ();
    event locacaoDenunciada (address locatarioDenunciado, string imovelDesocupado);
    
    constructor (
        string memory nomeComprador, 
        string memory nomeVendedor,
        uint256 precoDeAquisicao,
        address payable contaDoVendedor
        )
        public {
            comprador = nomeComprador;
            vendedor = nomeVendedor;
            preco = precoDeAquisicao;
            contaDoVendedor = contaVendedor;
            valorParcela = preco/parcelas;
        }
        
    function ajustaPreco (uint256 debitoIPTU) public {
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
   
   function realizarAquisicao () public payable {
       require (now > prazoPreferencia, "Aguardar transcurso do prazo legal para exercício de preferência dos locatários.");
       require (!preferenciaExercida, "Direito de preferência exercido por locatário.");
       require (msg.sender == contaComprador);
       require (msg.value == preco, "Valor diferente do acordado.");
       aquisicaoRealizada = true;
       emit aquisicaoConcluida ();
    }
    
    function verificarLocacaoPassivelDeDenuncia () view public returns (address[]) {
        
    }
    
    function denunciarLocacao () public {
        require (now <= prazoDenunciaLocacao, "Decorrido o prazo para denúncia da locação.");
        require (aquisicaoRealizada == true);
        require (locatarios.!contratoVigentePorPrazoDeterminado, locatatios.!haClausulaDeVigencia, locatarios.!contratoAverbadoNoRI, "A legislação não permite a denúncia desta locação."); // Requisitos do art. 8º da Lei Federal nº 8.245/1991
        emit locacaoDenunciada (address locatarioDenunciado, string imovelDesocupado);
    }
}
