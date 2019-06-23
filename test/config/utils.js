
const inspect = (tag) => (arg) => {
    console.log(tag, arg);
    return arg;
}

const wait = (time) => new Promise((resolve) => { setTimeout(resolve, time) })

const now = () => Math.floor(Date.now() / 1000);

const daySeconds = () => (24 * 60 * 60);

const addDay = (days) => (time) => time + (days * daySeconds());

const addSeconds = (seconds) => (time) => time + seconds;

const zeroAddress = () => '0x0000000000000000000000000000000000000000';

module.exports = { now, daySeconds, addDay, zeroAddress, inspect, addSeconds, wait };