// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";

contract Words is ERC721URIStorage {
    using Counters for Counters.Counter;
    mapping (uint256 => Expression) private tokens;
    Counters.Counter private _tokenIds;
    address public signer;
    
    constructor(address _signer) ERC721("Expressions", "EXP") {
        signer = _signer;
    }

    struct Expression {
        string word;
        string definition;
    }

    function awardItem(string memory word, string memory definition, bytes calldata signature)
        public
        returns (uint256)
    {   
        require(_tokenIds.current() < 10000);

        bytes32 messageHash = getMessageHash(msg.sender, word, definition);

        require(verify(messageHash, signature), "Invalid Signature");

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        Expression memory expression = Expression(word, definition);
        tokens[newItemId] = expression;

        return newItemId;
    }

    function tokenURI(uint256 id) public view override(ERC721URIStorage) returns (string memory) {
            return generateUrl(tokens[id].word, tokens[id].definition);
    }

    function generateUrl(string memory word, string memory definition) private pure returns (string memory) {
        string memory url = string(abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes( string(abi.encodePacked(
                            '{"name" : "Expressions",', 
                            '"attributes":[{"trait_type": "Word","value":"',
                                word,
                                '"}, {"trait_type": "Definition","value":"',
                                   definition,
                                    '"}],"image": "',
                                    generateImage(word, definition),
                                '"}'
                              ))))));
    return url;
    }

    function generateImage(string memory word, string memory definition) private pure returns(string memory) {
        string memory svg1 = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink= "http://www.w3.org/1999/xlink" height="600" width="600"><rect width="600" height="600" style="fill:rgb(255, 255, 255); stroke-width:1; stroke:rgb(0, 0, 0);" /><text x="50%" y="35%" text-anchor="middle" font-family="Alex Brush" font-size="3em">';
        string memory svg2 = '</text><text font-size="2em" x="50%" y="60%" text-anchor="middle" font-family="Alex Brush">';
        string memory svg3 = '</text><style>@import url("https://fonts.googleapis.com/css2?family=Alex+Brush")</style></svg>';
        return string(abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(string(abi.encodePacked(svg1, word, svg2, definition, svg3))))));
    }

    function getMessageHash(
        address account,
        string memory word,
        string memory definition
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, word, definition));
    }

    function verify(bytes32 messageHash, bytes memory signature)
        internal
        view
        returns (bool)
    {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function getEthSignedMessageHash(bytes32 messageHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory signature)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(signature.length == 65, "invalid signature length");

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}
