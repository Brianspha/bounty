pragma solidity >= 0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
event __StatementCoverage(uint32 value);
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal  returns (uint256) {
emit __StatementCoverage(5000001);
        uint256 c = a + b;
emit __StatementCoverage(5000002);
        require(c >= a, "SafeMath: addition overflow");

emit __StatementCoverage(5000003);
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal  returns (uint256) {
emit __StatementCoverage(5000004);
        require(b <= a, "SafeMath: subtraction overflow");
emit __StatementCoverage(5000005);
        uint256 c = a - b;

emit __StatementCoverage(5000006);
        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal  returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
emit __StatementCoverage(5000007);
        if (a == 0) {
emit __StatementCoverage(5000008);
            return 0;
        }

emit __StatementCoverage(5000009);
        uint256 c = a * b;
emit __StatementCoverage(5000010);
        require(c / a == b, "SafeMath: multiplication overflow");

emit __StatementCoverage(5000011);
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal  returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
emit __StatementCoverage(5000012);
        require(b > 0, "SafeMath: division by zero");
emit __StatementCoverage(5000013);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

emit __StatementCoverage(5000014);
        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal  returns (uint256) {
emit __StatementCoverage(5000015);
        require(b != 0, "SafeMath: modulo by zero");
emit __StatementCoverage(5000016);
        return a % b;
    }
}
