drop table if exists fluxo cascade;
drop table if exists fases cascade;
drop table if exists modalidades cascade;
drop table if exists setores cascade;
drop table if exists usuarios cascade;
drop table if exists processos cascade;
drop table if exists logs cascade;
drop table if exists demandas cascade;
drop table if exists categorias_demandas cascade;
drop type if exists tipo_perfil cascade;
drop type if exists situacao_processo cascade;
drop type if exists situacao_demanda cascade;
drop type if exists tipo_tramitacao cascade;

create type tipo_perfil as enum ('admin', 'agente', 'servidor', 'visitor');

create type  situacao_processo as enum ('Em tramitação', 'Pausa(Adequação)', 'Cancelado', 'Concluído', 'Deserto');

create type situacao_demanda as enum ('Iniciado', 'Não Iniciado', 'Concluído');

create type tipo_tramitacao as enum('Pausa/Adequação', 'Avanço', 'Retorno');


create table setores(
	id serial primary key,
	sigla varchar(15) unique,
	nome_relatorio varchar(50) unique,
	email  varchar(40) unique
);

create table modalidades(
	id serial primary key,
	nome_modalidade varchar(40)
);

create table fases(
	id serial primary key,
	nome_fase VARCHAR(30) unique,
	descricao_fase text not null
);

create table fluxo(
	id serial PRIMARY KEY,
	ordem_fluxo int NOT NULL,
	id_modalidade int,
	descricao_etapa text NOT NULL,
	id_setor int,
	prazo int,
	id_fase int,
	ultima_etapa boolean default false,
	
	constraint fk_fluxo_modalidade foreign key (id_modalidade) REFERENCES modalidades(id) on delete cascade,
	constraint FK_fluxo_setor foreign key (id_setor) references setores(id) on delete set null,
	constraint fk_fluxo_fase foreign key (id_fase) references fases(id) on delete set null
);

create table usuarios(
	id serial primary key,
	nome varchar(150) not null,
	email_institucional varchar(150) not null unique,
	id_setor int,
	role tipo_perfil,
	
	constraint fk_usuario_setor foreign key (id_setor) references setores(id) on delete set null
)

create table processos(
	id serial primary key,
	numero_processo varchar(40) unique not null,
	resumo text not null,
	id_setor_demandante int,
	email_servidor_demandante varchar(150) not null,
	id_modalidade int,
	id_etapa int,
	data_atualizacao timestamp default current_timestamp,
	id_servidor int,
	email_cadastro varchar(150) not null,
	data_abertura_sei timestamp,
	data_encaminhamento timestamp,
	data_cadastro timestamp default current_timestamp,
	situacao situacao_processo,
	
	constraint fk_processo_modalidade foreign key (id_modalidade) REFERENCES modalidades(id),
	constraint FK_processo_setor_demandante foreign key (id_setor_demandante) references setores(id) on delete set null,
	constraint fk_processo_servidor foreign key (id_servidor) references usuarios(id) on delete set null
)

create table logs(
	id serial primary key,
	id_processo int,
	id_etapa_origem int,
	id_etapa_destino int,
	tramitacao tipo_tramitacao not null,
	observacao text,
	id_servidor int,
	dias_totais int,
	data_tramite timestamp,
	
	constraint fk_log_processo foreign key (id_processo) REFERENCES processos(id),
	constraint fk_log_setor_origem foreign key (id_etapa_origem) references setores(id) on delete set null,
	constraint fk_log_setor_destino foreign key (id_etapa_destino) references setores(id) on delete set null,
	constraint fk_log_servidor foreign key (id_servidor) references usuarios(id) on delete set null
)

create table categorias_demandas(
	id serial primary key,
	nome_categoria varchar(30)
)

create table demandas(
	id serial primary key,
	id_processo int,
	id_setor_demandante int,
	numero_dfd varchar(30) not null,
	numero_contratacao varchar(30) not null,
	extemporanea boolean not null,
	titulo text,
	id_categoria int,
	data_estimada_de_inicio timestamp,
	ano int not null,
	situacao situacao_demanda default 'Não Iniciado',
	data_contratacao date,
	valor_unitario numeric(15, 2) default 0.00,
	quantidade_itens int default 1,
	valor_total numeric(15, 2) generated always as (valor_unitario * quantidade_itens) stored,
	
	constraint fk_demanda_setor foreign key (id_setor_demandante) references setores(id) on delete set null,
	constraint fk_demanda_processo foreign key (id_processo) references processos(id) on delete set null,
	constraint fk_demanda_categoria foreign key (id_categoria) references categorias_demandas(id) on delete set null
)
