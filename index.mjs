import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
import { ask } from '@reach-sh/stdlib';

const role = process.argv[2];

const stdlib = loadStdlib(process.env);
console.log(`The consensus network is ${stdlib.connector}.`);

const suStr = stdlib.standardUnit;
const auStr = stdlib.atomicUnit;
const toAU = (su) => stdlib.parseCurrency(su);
const toSU = (au) => stdlib.formatCurrency(au, 4);
const iBalance = toAU(10);
const showBalance = async (acc) => console.log(`Your balance is ${toSU(await stdlib.balanceOf(acc))} ${suStr}.`);

const commonInteract = (role) => ({
    reportError: () => { console.log(`${role == 'pa' ? 'PA' : 'You'} are not allowed on this transaction.`); },
    reportTransfer: (payment) => { console.log(`The contract paid ${toSU(payment)} ${suStr} to ${role == 'pa' ? 'PA' : 'to you'}.`) },
});

const accA = await stdlib.newTestAccount(iBalance);
const ctcA = accA.contract(backend);

if (role === 'pa') {
    const PAInteract = {
      ...commonInteract(role),
      price: toAU(2),
      addressA: 'secret place',
      reportReady: async (address) => {
        console.log(`Your contract address is ${address}.`);
      },
      checkAddress: async (address) => {
        return address === addressA;
      }
    };

    await showBalance(accA);
    await ctcA.p.PA(PAInteract);
    await showBalance(accA);
} else {
    const PBInteract = {
        ...commonInteract(role),
        storeAddress: async () => await ask.ask(`What is you address?`, (s) => s),
      };
    const accB = await stdlib.newTestAccount(iBalance);
    await showBalance(accB);
    const address = await ask.ask('What is you address?', (s) => s);

    if( address === 's'){
        console.log('in!')
        const ctcB = accB.contract(backend, ctcA.getInfo());
        await ctcB.p.PB(PBInteract);
        await showBalance(accB); 
    }

};

ask.done();