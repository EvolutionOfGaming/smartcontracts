
/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.0;

interface IEvolveBulkSender{
    function factoryAddress() external view returns(address);
    function updateFactoryAddress(address _newFactoryAddress) external returns(bool);
    function bulkReceive(uint256 _amount, address[] memory _payers, address _ERCTokenAddress) external returns (bool);
    function bulkWithdraw(uint256 _amount, address[] memory _receivers, address _ERC20Address) external returns(bool);

}