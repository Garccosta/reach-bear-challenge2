'reach 0.1';

const commonInteract = {
    reportTransfer: Fun([UInt], Null),
    reportError: Fun([], Null),
};

const PAInteract = {
    ...commonInteract,
    addressA: Bytes(128),
    price: UInt,
    reportReady: Fun([Bytes(128)], Null),
    checkAddress: Fun([Bytes(128)], Bool),
}

const PBInteract = {
    ...commonInteract,
    addressB: Bytes(128),
    storeAddress: Fun([], Bytes(128))
}

export const main = Reach.App(() => {
    const PA = Participant('PA', PAInteract);
    const PB = Participant('PB', PBInteract);

    init();

    PA.only(() => { 
        const addressA = declassify(interact.addressA);
    });
    PA.publish(addressA);
    PA.interact.reportReady(addressA);
    commit();

    PB.only(() => {
        const addressB = declassify(interact.storeAddress());
    })
    PB.publish(addressB);
    commit();

    PA.only(() => {
        const valid = declassify(interact.checkAddress(addressB));
    });
    PA.publish(valid);

    if (!valid) {
        commit();
        each([PA, PB], () => interact.reportError());
        exit();
    } else {
        commit();
        PA.only(() => {
            const price = declassify(interact.price);
        })
        PA.publish(price);
        commit();
        
        PA.pay(price);
        each([PA, PB], () => interact.reportTransfer(price));
        transfer(price).to(PB);
        commit();
    }

    exit();
});

//Participant A tells the contract who participant B is. The address should be stored in a Map or Set. 
//Your contract should then check who the attacher is and only allow the swap if the addresses match.

//Your program should include basic console messages that indicate the general status of the contract.

//The quantity of tokens swapped is arbitrary, choose any number you like.

    //const set = new Set();
    //set.add('secret place');