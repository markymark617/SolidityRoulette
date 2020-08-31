pragma solidity ^0.5.0;

interface ERC20Token {
    function getTotalSupply() external view returns (uint256);
    function getBalanceOf(address account) external view returns (uint256);
    function getAllowance(address owner, address spender) external view returns (uint256);

    /**
    * function transfer() is the transferTo() function and must trigger/emit Transfer event
    */
    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    //from https://eips.ethereum.org/EIPS/eip-20
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
