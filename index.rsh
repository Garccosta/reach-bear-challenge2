'reach 0.1';

const commonInteract = {
    reportTransfer: Fun([UInt], Null),
    reportError: Fun([UInt], Null),
    reportPayment: Fun([UInt], Null),
};

const PAInteract = {
    ...commonInteract,
    addressA: Bytes(128),
    price: UInt,
    reportReady: Fun([], Null),
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
        const map = new Map();
        map.set('address', 'secret place');
        const addressA = declassify(interact.addressA);
    });
    PA.publish(addressA);
    PA.interact.reportReady();
    commit();

    PB.only(() => {
        const addressB = declassify(interact.storeAddress());
    })
    PB.publish(addressB);
    commit();

    PA.only(() => {
        const isRightAdress = declassify(interact.checkAddress(addressB));
        const price = declassify(interact.price);
    });
    if(!isRightAdress) {
        commit();
        each([PA, PB], () => interact.reportError());
        exit();
    } else {
        PA.pay(price);
        transfer(price).to(PB);
        each([PA, PB], () => interact.reportPayment(price));
        commit();
    }

    exit();

});

//Participant A tells the contract who participant B is. The address should be stored in a Map or Set. 
//Your contract should then check who the attacher is and only allow the swap if the addresses match.

//Your program should include basic console messages that indicate the general status of the contract.

//The quantity of tokens swapped is arbitrary, choose any number you like.
