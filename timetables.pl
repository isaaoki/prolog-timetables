% FATOS DAS DATAS E HORARIOS 
dias_semana([seg, ter, qua, qui, sex]).

horario(8).
horario(10).
horario(14).

turno(1, 8, professor).
turno(1, 10, professor).
turno(1, 14, professor).

% FATOS E REGRAS DAS DISPONIBILIDADES DAS PESSOAS
disponivel(tinos, seg).
disponivel(tinos, qua).
disponivel(tinos, sex).
disponivel(bara, qui).
disponivel(bara, 14).
disponivel(joca, 10).
disponivel(vanessa, 8).
disponivel(vanessa, 10).
disponivel(vanessa, ter).
disponivel(vanessa, qui).
disponivel(mirela, qui).
disponivel(mirela, 8).

% REGRAS DE DISPONIBILIDADE
disponivel(Pessoa, Horario) :-
	horario(Horario),
	disponivel_a_partir(Pessoa, HorarioInicio),
	horario(HorarioInicio),
	disponivel_ate(Pessoa, HorarioFim),
	horario(HorarioFim),
	Horario >= HorarioInicio, 
	Horario < HorarioFim.

disponivel(Pessoa, Horario) :-
    \+ disponivel_ate(Pessoa, horario(_)),
    disponivel_a_partir(Pessoa, HorarioInicio),
    horario(HorarioInicio),
    horario(Horario),
    Horario >= HorarioInicio.

disponivel(Pessoa, Dia) :-
	dias_semana(Dias), 
	nth1(N, Dias, Dia),
	disponivel_a_partir(Pessoa, DiaInicio),
	nth1(NInicio, Dias, DiaInicio),
	disponivel_ate(Pessoa, DiaFim),
	nth1(NFim, Dias, DiaFim),
	N >= NInicio,
	N =< NFim.

disponivel_a_partir(tinos, 10).
disponivel_a_partir(joca, seg).
disponivel_a_partir(michele, ter).
disponivel_a_partir(michele, 8).

disponivel_ate(joca, qua).
disponivel_ate(michele, qua).

disponivel_dia_horario(Pessoa, Dia, Horario) :-
	dias_semana(Dias),
	member(Dia, Dias),
	horario(Horario),
	disponivel(Pessoa, Dia),
	disponivel(Pessoa, Horario).

% Para testar: cria lista com os dias/horarios disponiveis de uma pessoa
dias_disponiveis(Pessoa, DiasDisponiveis) :-
	dias_semana(Dias),
	findall(Dia, (
		member(Dia, Dias),
		disponivel(Pessoa, Dia)
	), DiasDisponiveis).

horarios_disponiveis(Pessoa, HorariosDisponiveis) :-	
	findall(Horario, (
		horario(Horario),
		disponivel(Pessoa, Horario)
	), HorariosDisponiveis).

dias_horarios_disponiveis(Dia, Horario, Disponibilidade) :-
	findall(Pessoa, (
		disponivel_dia_horario(Pessoa, Dia, Horario)
	), Disponibilidade).

% REGRAS DE PREFERENCIA
prefere(Pessoa, Horario) :-
	horario(Horario),
	prefere_a_partir(Pessoa, HorarioInicio),
	horario(HorarioInicio),
	prefere_ate(Pessoa, HorarioFim),
	horario(HorarioFim),
	Horario >= HorarioInicio, 
	Horario < HorarioFim.

prefere(Pessoa, Horario) :-
    horario(HorarioFim),
    \+ prefere_ate(Pessoa, HorarioFim),
    prefere_a_partir(Pessoa, HorarioInicio),
    horario(HorarioInicio),
    horario(Horario),
    Horario >= HorarioInicio.

prefere(Pessoa, Dia) :-
	dias_semana(Dias), 
	nth1(N, Dias, Dia),
	prefere_a_partir(Pessoa, DiaInicio),
	nth1(NInicio, Dias, DiaInicio),
	prefere_ate(Pessoa, DiaFim),
	nth1(NFim, Dias, DiaFim),
	N >= NInicio,
	N =< NFim.

% Para testar: cria lista com os dias disponiveis de uma pessoa
dias_preferencia(Pessoa, DiasPreferencia) :-
	dias_semana(Dias),
	findall(Dia, (
		member(Dia, Dias),
		prefere(Pessoa, Dia)
	), DiasPreferencia).

% Relações de gostar e não gostar que limitam

% MONTAR CRONOGRAMA

% Gera o cronograma de um dia
cronograma_dia(Dia, Cronograma) :-
	% Obtem lista dos horarios
	findall(Horario, horario(Horario), Horarios),
	% Retorna cronograma passando por cada horario
	cronograma_horarios(Dia, Horarios, Cronograma).

% Caso base: não há mais horários, o cronograma é vazio
cronograma_horarios(_, [], []).

% Caso 1: Grupos é uma lista vazia [] (nao ha pessoas disponiveis nesse horario)
cronograma_horarios(Dia, [Horario | Resto], [[] | RestoGrupos]) :-
	grupos_possiveis(Dia, Horario, Grupos),
	Grupos == [], !,
	cronograma_horarios(Dia, Resto, RestoGrupos).

% Caso 2: Gera os grupos possiveis do horario e escolhe um grupo possível
% Continua até acabar horários
cronograma_horarios(Dia, [Horario | Resto], [Grupo | RestoGrupos]) :-
	grupos_possiveis(Dia, Horario, Grupos),
	member(Grupo, Grupos),
	cronograma_horarios(Dia, Resto, RestoGrupos).

% Retorna os grupos possiveis de um determinado turno
grupos_possiveis(Dia, Horario, Grupos) :-
	turno(Quantidade, Horario, Funcao),
	% Acha todas as pessoas disponiveis naquele dia e horario
	findall((Horario, Pessoa, Funcao), disponivel_dia_horario(Pessoa, Dia, Horario), Disponiveis),
	% Acha toda as combinacoes possiveis da lista disponiveis com a quantidade do turno
	findall(Grupo, combinar(Quantidade, Disponiveis, Grupo), Grupos).

remover_pessoa(TuplasHorarioEntrada, TuplasHorarioSaida, MaxPessoas) :-
	
	delete(TuplasHorarioEntrada, Element, TuplasHorarioMeio),
	remover_pessoa(TuplasHorarioMeio, TuplasHorarioSaida, MaxPessoas).
	
filtrar_horario(TuplasHorarioEntrada, TuplasDisponiveisFiltrada) :-
	remover_pessoa(TuplasHorarioEntrada, TuplasHorarioFiltrada).

% PREDICADOS ADICIONAIS
% combinar(+Quantidade, +Lista, -Combinacoes)
% Caso base: lista vazia tem combinações com uma lista vazia
combinar(0, _, []).
% Caso 1: inclui o primeiro elemento nas combinacoes, encontra K-1 elementos entre os restantes
combinar(K, [X | T1], [X | T2]) :-
	K > 0, 
	K1 is K -1,
	combinar(K1, T1, T2).
% Caso 2: ignora o primeiro elemento na lista de combinações, encontra K elementos entre os restantes
combinar(K, [_ | T1], T2) :-
	K > 0,
	combinar(K, T1, T2).