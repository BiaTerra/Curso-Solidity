// SPDX-License-Identifier: GLP-3.0
pragma solidity 0.6.10;

contract CompraEVenda {
    
    string public comprador;
    string public vendedor;
    uint256 public preco;
    uint256 public constant parcelas = 10;
    uint256 public valorParcela;
    
    constructor (
        string memory nomeComprador, 
        string memory nomeVendedor,
        uint256 precoDeAquisicao
        )
        public {
            comprador = nomeComprador;
            vendedor = nomeVendedor;
            preco = precoDeAquisicao;
            valorParcela = preco/parcelas;
        }
        
    function ajustaPreco (uint256 debitoIPTU) public {
        if (debitoIPTU > 0) {
        preco = preco - debitoIPTU;
        valorParcela = preco/parcelas;
        }
    }
   
}
