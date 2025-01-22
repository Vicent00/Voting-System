// License
// SPDX-License-Identifier: LGPL-3.0-only


// Compiler version
pragma solidity 0.8.28;

/// @title Voting System - Decentralized voting system
/// @author Vicenga
/// @notice This contract allows creating an electoral voting system with voter and party registration, voting, and results consultation.



contract VotingSystem {
    // --- Structures ---

    struct Voter {
        bool registered; // Indicates if the voter is registered
        bool hasVoted;   // Indicates if the voter has already voted
        uint256 vote;    // Index of the party they voted for
    }

    struct Party {
        string name;       // Name of the political party
        uint256 voteCount; // Total number of votes received
    }

    // --- Variables ---
    address public admin;         // Administrator's address
    bool public votingOpen;       // Voting status (open or closed)
    Party[] public parties;       // List of political parties
    mapping(address => Voter) public voters; // Mapeo de votantes registrados
 
 // --- Modificadores ---
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyDuringVoting() {
        require(votingOpen, "Voting is not open");
        _;
    }

    // --- Eventos ---
    event PartyAdded(string name);                  // Evento cuando se agrega un partido
    event VoterRegistered(address voter);           // Evento cuando se registra un votante
    event VoteCast(address voter, uint256 partyIndex); // Evento cuando un votante emite un voto
    event VotingStatusChanged(bool isOpen);         // Evento cuando cambia el estado de votación

    

    // --- Constructor ---
    /// @notice Inicializa el contrato y asigna al creador como administrador
    constructor() {
        admin = msg.sender; // Asigna al creador del contrato como administrador
    }

    // --- Funciones de Gestión ---
    /// @notice Agrega un nuevo partido político
    /// @param _name Nombre del partido político
    function addParty(string memory _name) external onlyAdmin {
        parties.push(Party({ name: _name, voteCount: 0 }));
        emit PartyAdded(_name);
    }

    /// @notice Registra un nuevo votante
    /// @param _voter Dirección del votante a registrar
    function registerVoter(address _voter) external onlyAdmin {
        require(!voters[_voter].registered, "Voter is already registered");
        voters[_voter] = Voter({ registered: true, hasVoted: false, vote: 0 });
        emit VoterRegistered(_voter);
    }

    /// @notice Cambia el estado de la votación (abrir o cerrar)
    /// @param _status Estado de la votación (true = abierta, false = cerrada)
    function setVotingStatus(bool _status) external onlyAdmin {
        votingOpen = _status;
        emit VotingStatusChanged(_status);
    }

    // --- Funciones de Votación ---
    /// @notice Permite a un votante registrado emitir su voto
    /// @param _partyIndex Índice del partido político al que se quiere votar
    function vote(uint256 _partyIndex) external onlyDuringVoting {
        Voter storage sender = voters[msg.sender];
        require(sender.registered, "You are not registered to vote");
        require(!sender.hasVoted, "You have already voted");
        require(_partyIndex < parties.length, "Invalid party index");

        sender.hasVoted = true;
        sender.vote = _partyIndex;

        parties[_partyIndex].voteCount++;
        emit VoteCast(msg.sender, _partyIndex);
    }

    // --- Funciones de Consulta ---
    /// @notice Devuelve la lista de partidos políticos
    /// @return Array de partidos con nombres y conteo de votos
    function getParties() external view returns (Party[] memory) {
        return parties;
    }

    /// @notice Devuelve el número total de votos de un partido
    /// @param _partyIndex Índice del partido político
    /// @return Número de votos recibidos por el partido
    function getPartyVotes(uint256 _partyIndex) external view returns (uint256) {
        require(_partyIndex < parties.length, "Invalid party index");
        return parties[_partyIndex].voteCount;
    }
}
