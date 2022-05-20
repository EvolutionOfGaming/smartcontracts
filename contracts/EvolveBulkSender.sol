/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IEvolveBulkSender.sol";

contract EvolveBulkSender is Context, Ownable, IEvolveBulkSender{
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    
    address private _factoryAddress ;

    constructor(){
        _factoryAddress = _msgSender();
    }

    /* -------------------------------------------------------------------------- */
    /*                                  Modifiers                                 */
    modifier onlyFactory {
        require(_msgSender() == _factoryAddress, "Only factory can call this method.");
        _;
    }
    modifier factoryOrOwner() {
        require(_msgSender() == factoryAddress() || _msgSender() == owner(), "To call this method you have to be owner or factory!");
        _;
    }
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                   Events                                   */
    
    event BulkReceive(address indexed _receiver, address[] indexed _payers, uint256 _amount, address _executor);
    event BulkWithdraw(address indexed _payer, address[] indexed _receiver, uint256 _amount, address _executor);
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                 factory funcs                              */
    function factoryAddress() public override view returns (address) {
        return _factoryAddress;
    }
    
    function updateFactoryAddress(address _newFactoryAddress) external override onlyOwner() returns(bool){
        _updateFactoryAddress(_newFactoryAddress);
        return true;
    }

    function _updateFactoryAddress(address _newFactoryAddress) private returns(bool){
        _factoryAddress = _newFactoryAddress;
        return true;
    }
    /* -------------------------------------------------------------------------- */

    function bulkReceive(uint256 _amount, address[] memory _payers, address _ERCTokenAddress) external override factoryOrOwner()  returns (bool) {
        _bulkReceive(_amount,_payers,_ERCTokenAddress );
        return true;
    }

    function _bulkReceive(uint256 _amount, address[] memory _payers, address _ERCTokenAddress) private {
        require(_factoryAddress != address(0) , "Factory address in not defined and we need for recieve amount!");

        IERC20 token = IERC20(_ERCTokenAddress);

        for (uint256 i = 0; i < _payers.length; i++ ){
            token.safeTransferFrom(_payers[i], _factoryAddress , _amount);
        }

        emit BulkReceive( _factoryAddress, _payers , _amount, _msgSender());
    }

    function bulkWithdraw(uint256 _amount, address[] memory _receivers, address _ERC20Address) external override  factoryOrOwner() returns(bool) {
        _bulkWithdraw(_amount, _receivers, _ERC20Address);
        return true;
    }

    function _bulkWithdraw(uint256 _amount, address[] memory _receivers, address _ERC20Address) private  {
        require(_factoryAddress != address(0) , "Factory address in not defined and we need for pay amount!");

        IERC20 token = IERC20(_ERC20Address);

        for (uint256 i = 0; i < _receivers.length; i++ ){
            token.safeTransferFrom( _factoryAddress, _receivers[i], _amount);
        }

        emit BulkWithdraw(_factoryAddress, _receivers, _amount, _msgSender());
    }

}