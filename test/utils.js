const inspect = (arg) => {
    console.log(arg);
    return arg;
}

const now = () => Math.floor(Date.now() / 1000);

const daySeconds = () => (24 * 60 * 60);

const addDay = (days) => (time) => time + (days * daySeconds());

const zeroAddress = () => '0x0000000000000000000000000000000000000000';

module.exports = { now, daySeconds, addDay, zeroAddress, inspect };