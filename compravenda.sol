// SPDX-License-Identifier: GLP-3.0
pragma solidity 0.6.10;

contract CompraEVenda {
    
    struct Locatario {
        string nomeLocatario;
        string imovelAlugado;
    }
    
    string public comprador;
    address payable public contaComprador;
    string public vendedor;
    address payable public contaVendedor;
    uint256 public preco;
    uint256 public constant parcelas = 10;
    uint256 public valorParcela;
    uint256 public prazoPreferencia = now + 2592000;
    bool public preferenciaExercida;
    
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
   
   function exercerPreferencia () public payable {
       require (now <= prazoPreferencia, "Decorrido o prazo legal para exercício do direito de preferência."); // cf. art. 28 da Lei Federal nº 8.245/1991
       require (msg.value == preco, "O direito de preferência deve ser exercício em igual condição a terceiros."); // cf. art. 27 da Lei Federal nº 8.245/1991
       require (!preferenciaExercida, "Direito de preferência já exercido por outro locatário.");
       preferenciaExercida = true;
    }
   
   function realizarAquisicao () public payable {
       require (now > prazoPreferencia, "Aguardar transcurso do prazo legal para exercício de preferência dos locatários.");
       require (!preferenciaExercida, "Direito de preferência exercido por locatário.");
       require (msg.sender == contaComprador);
       require (msg.value == preco, "Valor diferente do acordado.");
       }
   
}
