-- Confirmaciones que llegan desde el formulario de la invitación.
-- Correr una sola vez en Supabase → SQL Editor (proyecto renovacion-votos).

create table if not exists public.rsvps (
    id bigint generated always as identity primary key,
    nombre text not null,
    asistencia text not null,
    restricciones text,
    guest_index int,            -- posición en la lista del panel; null = falta asignar
    created_at timestamptz not null default now()
);

alter table public.rsvps enable row level security;

drop policy if exists "rsvps insert" on public.rsvps;
drop policy if exists "rsvps select" on public.rsvps;
drop policy if exists "rsvps update" on public.rsvps;
create policy "rsvps insert" on public.rsvps for insert to anon with check (true);
create policy "rsvps select" on public.rsvps for select to anon using (true);
create policy "rsvps update" on public.rsvps for update to anon using (true) with check (true);

do $$ begin
    alter publication supabase_realtime add table public.rsvps;
exception when duplicate_object then null; end $$;

-- Confirmaciones que llegaron por correo (FormSubmit) antes de conectar el formulario.
insert into public.rsvps (nombre, asistencia, restricciones, guest_index, created_at) values
    ('Melissa del Valle',             'Sí, asistiré', null,                      18, '2026-08-19 03:26:16+00'),
    ('Laura Martínez',                'Sí, asistiré', null,                      40, '2026-08-19 03:34:09+00'),
    ('Juan Flórez',                   'Sí, asistiré', null,                      38, '2026-08-19 03:34:34+00'),
    ('Yolanda',                       'Sí, asistiré', null,                       6, '2026-08-19 03:59:51+00'),
    ('Stephanie Franco',              'Sí, asistiré', null,                      25, '2026-08-19 11:43:08+00'),
    ('Luis Alberto Sanín',            'Sí, asistiré', null,                       5, '2026-08-19 12:08:06+00'),
    ('Santiago Correa',               'Sí, asistiré', null,                      19, '2026-08-19 12:15:32+00'),
    ('Jorge Sebastián Vásquez Vanegas','Sí, asistiré', 'Hormigas',               67, '2026-08-19 12:55:11+00'),
    ('Víctor Paytuvi Hernández',      'Sí, asistiré', null,                      16, '2026-08-19 13:31:36+00'),
    ('Diana Sanín',                   'Sí, asistiré', 'No gluten',                7, '2026-08-19 14:35:28+00'),
    ('Santi Urán',                    'Sí, asistiré', null,                      65, '2026-08-19 14:51:32+00'),
    ('Carlos Patiño',                 'Sí, asistiré', null,                      31, '2026-08-20 23:09:27+00'),
    ('Camila Vega',                   'Sí, asistiré', null,                      49, '2026-08-20 23:09:55+00'),
    ('David León',                    'Sí, asistiré', 'Carnívoro',             null, '2026-08-23 14:33:22+00'),
    ('Joaquín León',                  'Sí, asistiré', 'Le encanta el chicharrón', 4, '2026-08-23 14:34:03+00'),
    ('Susana Cardona',                'Sí, asistiré', null,                      29, '2026-08-25 19:55:58+00'),
    ('Miguel Henao',                  'Sí, asistiré', null,                      27, '2026-08-25 23:44:08+00'),
    ('Rosa',                          'Sí, asistiré', null,                      26, '2026-08-26 01:07:39+00'),
    ('Susana Jaramillo',              'Sí, asistiré', null,                      34, '2026-08-28 02:36:37+00'),
    ('Daniel Ballesteros',            'Sí, asistiré', null,                      14, '2026-08-30 18:58:17+00');

-- Marcarlos como confirmados en el panel (status 2).
insert into public.guests (guest_index, status)
select guest_index, 2 from public.rsvps where guest_index is not null
on conflict (guest_index) do update set status = 2;
